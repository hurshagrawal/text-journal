defmodule Quilt.Repo.Migrations.RemoveIsUsNumberFlag do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove(:is_us_number)
    end
  end
end
