defmodule Journal.Repo.Migrations.CreateJournals do
  use Ecto.Migration

  def change do
    create table(:journals) do
      add(:type, :string, null: false)
      add(:phone_number, :integer, null: false)

      timestamps()
    end
  end
end
