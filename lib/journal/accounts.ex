defmodule Journal.Accounts do
  import Ecto.Query, warn: false
  alias Journal.Repo

  alias Journal.Accounts.User

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
  end

  def sanitize_name(name) do
  end

  def sanitize_phone_number(phone_number) do
  end
end
