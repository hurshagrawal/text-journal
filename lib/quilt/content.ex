defmodule Quilt.Content do
  import Ecto.Query, warn: false

  alias Ecto.Multi

  alias Quilt.Repo
  alias Quilt.Accounts
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
end
