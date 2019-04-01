defmodule Quilt.Repo.Migrations.AddIsUsNumberFlagToUsers do
  use Ecto.Migration

  alias Quilt.Accounts.User

  def up do
    alter table(:users) do
      add(:is_us_number, :boolean, null: false, default: true)
    end

    flush()

    users = repo().all(User)

    Enum.each(users, fn user ->
      user
      |> User.changeset(%{
        is_us_number: User.is_us_phone_number?(user.phone_number)
      })
      |> repo().update!()
    end)
  end

  def down do
    alter table(:users) do
      remove(:is_us_number)
    end
  end
end
