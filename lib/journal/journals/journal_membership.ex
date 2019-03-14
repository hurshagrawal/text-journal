defmodule Journal.Journals.JournalMembership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "journal_memberships" do
    field :type, :string
    field :journal_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(journal_membership, attrs) do
    journal_membership
    |> cast(attrs, [:type])
    |> validate_required([:type])
  end
end
