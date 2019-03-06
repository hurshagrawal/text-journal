defmodule Journal.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset


  schema "rooms" do
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:type])
    |> validate_required([:type])
  end
end
