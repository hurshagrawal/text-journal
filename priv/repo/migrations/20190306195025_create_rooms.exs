defmodule Journal.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add(:type, :string, null: false)
      add(:phone_number, :integer, null: false)

      timestamps()
    end
  end
end
