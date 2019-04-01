defmodule Quilt.Repo.Migrations.CleanUpExtraUserFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove(:verification_code_expires_at)
      remove(:last_login_at)
    end
  end
end
