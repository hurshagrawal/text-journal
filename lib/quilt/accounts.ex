defmodule Quilt.Accounts do
  import Ecto.Query, warn: false
  alias Quilt.Repo

  alias Quilt.Accounts.User

  @doc """
  Gets a single user.
  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

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
