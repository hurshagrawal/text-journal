defmodule Quilt.Repo.Migrations.AddUniqueConstraintToUserPhone do
  use Ecto.Migration

  def change do
    create(unique_index(:users, [:phone_number]))
  end
end
