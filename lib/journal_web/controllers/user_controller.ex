defmodule JournalWeb.UserController do
  use JournalWeb, :controller

  alias Journal.Accounts
  alias Journal.Sms
  alias Journal.Accounts.User

  @doc """
  Site homepage. Loads the signup/login page if signed out, or
  redirects to the main journal page if signed in.
  """
  def index(conn, _params, current_user) do
    if current_user != nil do
      render(conn, "logged_out_index.html")
    else
      redirect(conn, to: Routes.journal_path(conn, :index))
    end
  end

  @doc """
  Creates a user given a name and phone number.
  """
  def create(conn, %{"phone_number" => phone_number}, current_user)
      when Accounts.sanitize_phone_number(phone_number) == "" do
    conn
    |> put_flash(:error, "Please enter a valid phone number.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

  def create(conn, %{"name" => name}, current_user)
      when Accounts.sanitize_name(name) == "" do
    conn
    |> put_flash(:error, "Please enter a valid name.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

  def create(conn, %{"name" => name, "phone_number" => phone_number}, current_user) do
    user_params = %{
      name: Accounts.sanitize_name(name),
      phone_number: Accounts.sanitize_phone_number(phone(number))
    }

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        user = Accounts.regenerate_verification_code(user)
        Sms.send_verification_code(user.number, user.verification_code)

        conn
        |> put_session(:user_to_verify_id, user.id)
        |> redirect(to: Routes.user_path(conn, :verify_index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Oops! Something went wrong when trying to register.")
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end

  @doc """
  Loads the phone verification page after a user tries to register or sign in.
  """
  def verify_index(conn, _params, _current_user) do
    with user_id when user_id != nil <- get_session(conn, :user_to_verify_id),
         user when user != nil <- Accounts.get_user(user_id)
    do
      render(conn, "verify.html")
    else
      conn
      |> put_flash(:error, "Please re-enter your phone number.")
      |> redirect(to: Routes.user_path(conn, :index))
    end
  end

  @doc """
  Verifies a phone number and signs the user in.
  """
  def verify_phone(conn, %{"code" => code}, _current_user) do
    with user_id when user_id != nil <- get_session(conn, :user_to_verify_id),
         user when user != nil <- Accounts.get_user(user_id)
    do
      if user.verification_code == String.trim(code) do
        conn
        # TODO: Sign in via guardian
        |> redirect(to: Routes.user_path(conn, :index))
      else
        conn
        |> put_flash(:error, "That code didn't match. Please retry sending a code.")
        |> redirect(to: Routes.user_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Please re-enter your phone number and try logging in again.")
      |> redirect(to: Routes.user_path(conn, :index))
    end
  end
end
