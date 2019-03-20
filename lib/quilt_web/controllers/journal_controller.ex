defmodule QuiltWeb.JournalController do
  use QuiltWeb, :controller
  use QuiltWeb.GuardedController

  alias Quilt.Accounts
  alias Quilt.Accounts.User
  alias Quilt.Content
  alias Quilt.Content.Journal

  plug :ensure_authenticated

  def index(conn, _params, current_user) do
    journal = Content.get_user_journal(current_user)
    render(conn, "index.html", journal: journal)
  end

  def create(conn, %{"name" => name}, current_user) do
    case Content.create_user_journal(current_user, %{name: name}) do
      {:ok, %{journal: journal}} ->
        # TODO: Get a new number from Twilio + update the journal
        conn
        |> redirect(to: Routes.journal_path(conn, :index))

      {:error, _failed_operation, %Ecto.Changeset{} = changeset, _changes} ->
        error_messages = Enum.join(changeset_errors(changeset), ", ")

        conn
        |> put_flash(:error, "Oops! #{String.capitalize(error_messages)}.")
        |> redirect(to: Routes.journal_path(conn, :index))
    end
  end

  def update(conn, %{"journal" => journal_params}, current_user) do
  end
end
