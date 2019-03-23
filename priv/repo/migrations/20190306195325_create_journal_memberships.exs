defmodule Quilt.Repo.Migrations.CreateJournalMemberships do
  use Ecto.Migration

  def change do
    create table(:journal_memberships) do
      add(:type, :string, null: false)
      add(:subscribed, :boolean, null: false, default: true)
      add(:journal_id, references(:journals, on_delete: :nothing), null: false)
      add(:user_id, references(:users, on_delete: :nothing), null: false)

      timestamps()
    end

    create(index(:journal_memberships, [:journal_id]))
    create(index(:journal_memberships, [:user_id]))
  end
end
