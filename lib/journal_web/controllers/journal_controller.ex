defmodule JournalWeb.JournalController do
  use JournalWeb, :controller
  use JournalWeb.GuardedController

  alias Journal.Accounts
  alias Journal.Accounts.User
  alias Journal.Journals
  alias Journal.Journals.Journal

  plug :ensure_authenticated

  def index(conn, _params, current_user) do
    journal = Journals.get_user_journal(current_user)
    render(conn, "index.html", journal: journal)
  end

  def create(conn, %{"journal" => journal_params}, current_user) do
    case Journals.create_user_journal(current_user, journal_params) do
      {:ok, journal} ->
        conn
        |> redirect(to: Routes.journal_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        error_messages = Enum.join(changeset_errors(changeset), ", ")

        conn
        |> put_flash(:error, "Oops! #{String.capitalize(error_messages)}.")
        |> redirect(to: Routes.journal_path(conn, :index))
    end
  end

  def update(conn, %{"journal" => journal_params}, current_user) do
  end
end
