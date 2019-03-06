defmodule Journal.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :type, :string

      timestamps()
    end

  end
end
