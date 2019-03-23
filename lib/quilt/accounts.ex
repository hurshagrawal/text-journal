defmodule Quilt.Accounts do
  import Ecto.Query, warn: false
  alias Quilt.Repo

  alias Quilt.Accounts.User

  @doc """
  Gets a single user.
  """
  def get_user(id), do: Repo.get(User, id)

  def get_or_create_user(attrs) do
    query =
      from u in User,
        where: ^attrs,
        order_by: [desc: u.id],
        limit: 1

    case Repo.one(query) do
      nil ->
        attrs
        |> Enum.into(%{})
        |> create_user()

      user ->
        user
    end
  end

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Regenerates a user's verification code. Returns user.
  """
  def regenerate_verification_code(user) do
    user
    |> User.changeset(%{verification_code: Enum.random(10_000..99_999)})
    |> Repo.update()
  end
end
