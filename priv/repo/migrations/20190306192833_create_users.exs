defmodule Journal.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string, null: false)
      add(:verification_code, :string)
      add(:phone_number, :string, null: false)
      add(:phone_number_verified, :boolean, null: false, default: false)
      add(:last_login_at, :naive_datetime)

      timestamps()
    end
  end
end
