defmodule Journal.Rooms.RoomMembership do
  use Ecto.Schema
  import Ecto.Changeset


  schema "room_memberships" do
    field :type, :string
    field :room_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(room_membership, attrs) do
    room_membership
    |> cast(attrs, [:type])
    |> validate_required([:type])
  end
end
