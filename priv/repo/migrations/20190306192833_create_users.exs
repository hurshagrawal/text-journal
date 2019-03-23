defmodule Quilt.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string)
      add(:phone_number, :string, null: false)
      add(:verification_code, :integer)
      add(:verification_code_expires_at, :naive_datetime)
      add(:last_login_at, :naive_datetime)

      timestamps()
    end
  end
end
