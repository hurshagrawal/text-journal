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
    |> set_default_type()
    |> validate_required([:type, :journal_id, :user_id, :subscribed])
    |> unique_constraint(:journal_and_user,
      name: :users_journal_id_user_id_index
    )
  end

  def set_default_type(%Ecto.Changeset{} = changeset) do
    default_type = "subscriber"

    case fetch_change(changeset, :type) do
      :error -> put_change(changeset, :type, default_type)
      _ -> changeset
    end
  end

  def without_owner(query) do
    from jm in query, where: jm.type != "owner"
  end

  def subscribed(query) do
    from jm in query, where: jm.subscribed == true
  end
end
