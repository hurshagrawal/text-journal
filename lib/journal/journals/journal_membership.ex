defmodule Journal.Journals.JournalMembership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "journal_memberships" do
    field :type, :string

    belongs_to :journal, Journal.Journals.Journal
    belongs_to :user, Journal.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(journal_membership, attrs) do
    journal_membership
    |> cast(attrs, [:type, :journal_id, :user_id])
    |> validate_required([:type, :journal_id, :user_id])
  end
end
