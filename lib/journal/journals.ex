defmodule Journal.Journals do
  import Ecto.Query, warn: false

  alias Ecto.Multi

  alias Journal.Repo
  alias Journal.Accounts
  alias Journal.Accounts.User
  alias Journal.Journals.Journal
  alias Journal.Journals.Post
  alias Journal.Journals.JournalMembership

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
