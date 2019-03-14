defmodule JournalWeb.JournalController do
  use JournalWeb, :controller

  alias Journal.Accounts
  alias Journal.Accounts.User
  alias Journal.Journals
  alias Journal.Journals.Journal

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end

    # Send verification code to the phone number
  end

  def verify_phone(conn, %{"code" => code}) do
    # Verify the phone number
    #   if verified
    render(conn, "confirmation.html")
    #   if errored
    render(conn, "verify.html", error: "That code doesn't match. Try again?")
  end
end
