defmodule QuiltWeb.UserController do
  use QuiltWeb, :controller
  use QuiltWeb.GuardedController

  alias Quilt.{Accounts, Sms}

  plug :ensure_unauthenticated when action in [:index, :verify_index]

  @doc """
  Site homepage. Loads the signup/login page if signed out, or
  redirects to the main journal page if signed in.
  """
  def index(conn, _params, _current_user) do
    render(conn, "logged_out_index.html")
  end

  @doc """
  Creates a user given a name and phone number.
  """
  def create(conn, params, _current_user) do
    user_attrs = %{
      name: params["name"],
      phone_number: params["phone_number"]
    }

    case Accounts.create_user(user_attrs) do
      {:ok, user} ->
        {:ok, user} = Accounts.regenerate_verification_code(user)
        Sms.send_verification_code(user.phone_number, user.verification_code)

        conn
        |> put_session(:user_to_verify_id, user.id)
        |> redirect(to: Routes.user_path(conn, :verify_index))

      {:error, %Ecto.Changeset{} = changeset} ->
        error_messages = Enum.join(changeset_errors(changeset), ", ")

        conn
        |> put_flash(:error, "Oops! #{String.capitalize(error_messages)}.")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end

  @doc """
  Loads the phone verification page after a user tries to register or sign in.
  """
  def verify_index(conn, _params, _current_user) do
    with user_id when user_id != nil <- get_session(conn, :user_to_verify_id),
         user when user != nil <- Accounts.get_user(id: user_id) do
      render(conn, "verify.html")
    else
      _ ->
        conn
        |> put_flash(:error, "Please re-enter your phone number.")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end

  @doc """
  Verifies a phone number and signs the user in.
  """
  def verify_user(conn, %{"code" => code}, _current_user) do
    with user_id when user_id != nil <- get_session(conn, :user_to_verify_id),
         user when user != nil <- Accounts.get_user(id: user_id),
         {parsed_code, _} <- Integer.parse(String.trim(code)),
         true <- user.verification_code == parsed_code do
      conn
      |> sign_in(user)
      |> redirect(to: Routes.user_path(conn, :index))
    else
      _ ->
        conn
        |> put_flash(
          :error,
          "That code didn't match. Please retry your code."
        )
        |> redirect(to: Routes.user_path(conn, :verify_index))
    end
  end

  def sign_in(conn, %{"phone_number" => phone_number}, _current_user) do
    if Accounts.phone_number_valid?(phone_number) do
      sanitized_phone = Accounts.normalize_phone_number(phone_number)

      case Accounts.get_user(phone_number: sanitized_phone) do
        nil ->
          conn
          |> put_flash(:error, "Oops! No user was found with that number.")
          |> redirect(to: Routes.user_path(conn, :index))

        user ->
          {:ok, user} = Accounts.regenerate_verification_code(user)
          Sms.send_verification_code(user.phone_number, user.verification_code)

          conn
          |> put_session(:user_to_verify_id, user.id)
          |> redirect(to: Routes.user_path(conn, :verify_index))
      end
    else
      conn
      |> put_flash(:error, "Oops! That number isn't valid.")
      |> redirect(to: Routes.user_path(conn, :index))
    end
  end

  def sign_out(conn, _params, _current_user) do
    conn
    |> sign_out()
    |> redirect(to: Routes.user_path(conn, :index))
  end

  @doc """
  Authorization error for Guardian. Returns simple json error.
  """
  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(:forbidden)
    |> render(QuiltWeb.UserView, "error.json", message: "Not Authenticated")
  end
end
