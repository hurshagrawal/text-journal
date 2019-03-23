defmodule Quilt.Repo.Migrations.CreateJournals do
  use Ecto.Migration

  def change do
    create table(:journals) do
      add(:type, :string, null: false)
      add(:name, :string, null: false)
      add(:phone_number, :string)
      add(:onboarding_text, :text)
      add(:unsubscribe_text, :text)
      add(:subscriber_response_text, :text)

      timestamps()
    end
  end
end
