defmodule Journal.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :verification_code, :string
      add :phone, :integer
      add :last_login_at, :naive_datetime

      timestamps()
    end

  end
end
