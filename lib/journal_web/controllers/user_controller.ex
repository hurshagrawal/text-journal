defmodule JournalWeb.UserController do
  use JournalWeb, :controller
  use JournalWeb.GuardedController

  alias JournalWeb.Guardian

  alias Journal.Accounts
  alias Journal.Sms
  alias Journal.Accounts.User

  @doc """
  Site homepage. Loads the signup/login page if signed out, or
  redirects to the main journal page if signed in.
  """
  def index(conn, _params, current_user) do
    if current_user == nil do
      render(conn, "logged_out_index.html")
    else
      redirect(conn, to: Routes.journal_path(conn, :index))
    end
  end

  @doc """
  Creates a user given a name and phone number.
  """
  def create(conn, %{"name" => name, "phone_number" => phone_number}, _current_user) do
    case Accounts.create_user(%{name: name, phone_number: phone_number}) do
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
         user when user != nil <- Accounts.get_user(user_id) do
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
         user when user != nil <- Accounts.get_user(user_id),
         {parsed_code, _} <- Integer.parse(String.trim(code)) do
      if user.verification_code == parsed_code do
        conn
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: Routes.user_path(conn, :index))
      else
        conn
        |> put_flash(:error, "That code didn't match. Please retry sending a code.")
        |> redirect(to: Routes.user_path(conn, :index))
      end
    else
      _ ->
        conn
        |> put_flash(:error, "Please re-enter your phone number and try logging in again.")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(:forbidden)
    |> render(RealWorldWeb.UserView, "error.json", message: "Not Authenticated")
  end

  defp changeset_errors(%Ecto.Changeset{} = changeset) do
    changeset.errors
    |> Enum.map(fn {k, v} -> "#{k} #{render_detail(v)}" end)
  end

  defp render_detail({message, values}) do
    Enum.reduce(values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end)
  end

  defp render_detail(message) do
    message
  end
end
