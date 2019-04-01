defmodule Quilt.Content do
  import Ecto.Query, warn: false
  import Quilt.Helpers

  alias Ecto.Multi

  alias Quilt.{Repo, Sms, Accounts}
  alias Quilt.Accounts.User
  alias Quilt.Content.Journal
  alias Quilt.Content.Post
  alias Quilt.Content.JournalMembership

  @doc """
  Gets a user's journal.
  """
  def get_user_journal(user) do
    user
    |> Ecto.assoc(:owned_journals)
    |> limit(1)
    |> Repo.one()
  end

  def get_journals() do
    Repo.all(Journal)
  end

  def get_journal(attrs) do
    Repo.one(
      from j in Journal,
        where: ^attrs,
        order_by: [desc: j.id],
        limit: 1
    )
  end

  def get_membership(attrs) do
    Repo.get_by(JournalMembership, attrs)
  end

  def get_journal_owner_id(journal) do
    owner_membership =
      journal
      |> Ecto.assoc(:owner_journal_memberships)
      |> Repo.one()

    if owner_membership do
      owner_membership.user_id
    else
      nil
    end
  end

  def get_journal_posts(journal) do
    Repo.all(
      from p in Post,
        where: p.journal_id == ^journal.id,
        order_by: [asc: p.id],
        preload: [:user]
    )
  end

  def get_journal_subscribers_count(journal) do
    journal
    |> Ecto.assoc(:journal_memberships)
    |> JournalMembership.without_owner()
    |> JournalMembership.subscribed()
    |> Repo.aggregate(:count, :id)
  end

  def get_journal_unsubscribed_count(journal) do
    journal
    |> Ecto.assoc(:journal_memberships)
    |> JournalMembership.without_owner()
    |> JournalMembership.unsubscribed()
    |> Repo.aggregate(:count, :id)
  end

  def get_journal_owner_posts_count(journal) do
    owner_user_id = get_journal_owner_id(journal)

    journal
    |> Ecto.assoc(:posts)
    |> Post.with_user_id(owner_user_id)
    |> Repo.aggregate(:count, :id)
  end

  def get_journal_replies_count(journal) do
    owner_user_id = get_journal_owner_id(journal)

    journal
    |> Ecto.assoc(:posts)
    |> Post.without_user_id(owner_user_id)
    |> Repo.aggregate(:count, :id)
  end

  def get_subscriber_phone_numbers(journal) do
    query =
      from u in User,
        join: jm in assoc(u, :journal_memberships),
        where: jm.journal_id == ^journal.id,
        where: jm.type == "subscriber",
        where: jm.subscribed == true,
        select: [:phone_number]

    query
    |> Repo.all()
    |> Enum.map(fn user -> user.phone_number end)
  end

  @doc """
  Creates a journal for a user.
  """
  def create_user_journal(user, name) do
    attrs = %{
      name: name,
      onboarding_text: default_onboarding_text(),
      subscriber_response_text: default_subscriber_response_text()
    }

    result =
      Multi.new()
      |> Multi.insert(:journal, Journal.changeset(%Journal{}, attrs))
      |> Multi.insert(:journal_membership, fn %{journal: journal} ->
        Ecto.build_assoc(journal, :journal_memberships,
          user: user,
          type: "owner"
        )
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{journal: journal}} ->
        number = Sms.get_new_sms_number()
        update_journal(journal, %{phone_number: number})

        {:ok, journal}

      {:error, _failed_operation, %Ecto.Changeset{} = changeset, _changes} ->
        error_messages = Enum.join(changeset_errors(changeset), ", ")

        {:error, "Oops! #{String.capitalize(error_messages)}."}
    end
  end

  def create_post(journal, user, body, media_urls) do
    attrs = %{
      journal_id: journal.id,
      user_id: user.id,
      body: body,
      media_urls: media_urls
    }

    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Subscribes a user to a journal. Either creates a journal
  membership or subscribes an existing journal membership.
  """
  def subscribe_user(journal, user) do
    membership =
      case Repo.get_by(JournalMembership,
             journal_id: journal.id,
             user_id: user.id
           ) do
        nil -> %JournalMembership{}
        membership -> membership
      end

    membership
    |> JournalMembership.changeset(%{
      journal_id: journal.id,
      user_id: user.id,
      subscribed: true
    })
    |> Repo.insert_or_update!()
  end

  def unsubscribe_phone_number(phone_number, journal) do
    user = Accounts.get_user(phone_number: phone_number)

    case get_membership(journal_id: journal.id, user_id: user.id) do
      nil -> {:ok, nil}
      membership -> unsubscribe_membership(membership)
    end
  end

  def unsubscribe_membership(membership) do
    membership
    |> JournalMembership.changeset(%{subscribed: false})
    |> Repo.update!()
  end

  def update_journal(journal, attrs) do
    journal
    |> Journal.changeset(attrs)
    |> Repo.update!()
  end

  defp default_onboarding_text do
    "Hey! Thanks for subscribing to my journal. Add this # to your Contacts, and reply \"stop\" anytime if you decide you're over it."
  end

  defp default_subscriber_response_text do
    "Thanks for the message! We haven't built the ability for me to respond yet, but it should be done soon. Stay tuned!"
  end
end
