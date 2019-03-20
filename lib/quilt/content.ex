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