defmodule Journal.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :last_login_at, :naive_datetime
    field :name, :string
    field :phone, :integer
    field :verification_code, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :verification_code, :phone, :last_login_at])
    |> validate_required([:name, :verification_code, :phone, :last_login_at])
  end
end
