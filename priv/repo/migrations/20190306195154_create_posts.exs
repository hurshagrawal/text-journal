defmodule Journal.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:content, :text)
      add(:room_id, references(:rooms, on_delete: :nothing))
      add(:user_id, references(:users, on_delete: :nothing))

      timestamps()
    end

    create(index(:posts, [:room_id]))
    create(index(:posts, [:user_id]))
  end
end
