defmodule Quilt.Content do
  import Ecto.Query, warn: false

  alias Ecto.Multi

  alias Quilt.Repo
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
    |> Repo.one()
  end

  def get_journal(attrs) do
    Repo.get_by(Journal, attrs)
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

  def get_journal_subscribers_count(journal) do
    journal
    |> Ecto.assoc(:journal_memberships)
    |> JournalMembership.without_owner()
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
        where: [journal_id: ^journal.id],
        select: [u.phone_number]

    query
    |> Repo.all()
    |> Enum.map(fn user -> user.phone_number end)
  end

  @doc """
  Creates a journal for a user.
  """
  def create_user_journal(user, attrs) do
    Multi.new()
    |> Multi.insert(:journal, Journal.changeset(%Journal{}, attrs))
    |> Multi.insert(:journal_membership, fn %{journal: journal} ->
      Ecto.build_assoc(journal, :journal_memberships, user: user, type: "owner")
    end)
    |> Repo.transaction()
  end

  def create_post(journal, user, body, media_urls) do
    attrs = %{
      journal: journal,
      user: user,
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

  def default_onboarding_text do
    "Hey! Thanks for following my walk. I'll text you from this number each day once my walk begins on April 1st.\n\nAnd feel free to reply to my messages as well - or reply \"stop\" if you've had enough.\n\nFinally, add this number to your contacts book for the bext experience."
  end

  def default_unsubscribe_text do
    "Thanks for following along. I'll stop sending you messages now. Hope to see you again soon!"
  end

  def default_subscriber_response_text do
    "Hi there! I've decided to unplug during my walk and turn off all notifications. I'll see this when my walk ends. Keep the replies coming in the meantime!"
  end
end
