defmodule Journal.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:content, :text, null: false)
      add(:room_id, references(:rooms, on_delete: :nothing), null: false)
      add(:user_id, references(:users, on_delete: :nothing), null: false)

      timestamps()
    end

    create(index(:posts, [:room_id]))
    create(index(:posts, [:user_id]))
  end
end
