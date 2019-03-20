defmodule Quilt.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:content, :text, null: false)
      add(:journal_id, references(:journals, on_delete: :nothing), null: false)
      add(:user_id, references(:users, on_delete: :nothing), null: false)

      timestamps()
    end

    create(index(:posts, [:journal_id]))
    create(index(:posts, [:user_id]))
  end
end
