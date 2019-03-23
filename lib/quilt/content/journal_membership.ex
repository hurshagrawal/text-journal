defmodule Quilt.Content.JournalMembership do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "journal_memberships" do
    field :type, :string
    field :subscribed, :boolean

    belongs_to :journal, Quilt.Content.Journal
    belongs_to :user, Quilt.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(journal_membership, attrs) do
    journal_membership
    |> cast(attrs, [:type, :journal_id, :user_id, :subscribed])
    |> validate_required([:type, :journal_id, :user_id, :subscribed])
  end

  def without_owner(query) do
    from jm in query, where: jm.type != "owner"
  end

  def subscribed(query) do
    from jm in query, where: jm.subscribed == true
  end
end
