defmodule Journal.Repo.Migrations.CreateJournals do
  use Ecto.Migration

  def change do
    create table(:journals) do
      add(:type, :string, null: false)
      add(:phone_number, :string, null: false)
      add(:name, :string, null: false)
      add(:onboarding_text, :text, null: false)

      timestamps()
    end
  end
end
