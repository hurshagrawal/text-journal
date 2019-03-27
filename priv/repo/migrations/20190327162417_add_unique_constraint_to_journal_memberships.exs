defmodule Quilt.Repo.Migrations.AddUniqueConstraintToJournalMemberships do
  use Ecto.Migration

  def change do
    create(
      unique_index(:journal_memberships, [:journal_id, :user_id],
        name: :users_journal_id_user_id_index
      )
    )
  end
end
