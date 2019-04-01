defmodule QuiltWeb.Admin.JournalController do
  use QuiltWeb, :controller
  use QuiltWeb.GuardedController

  alias Quilt.{Accounts, Content}

  plug :ensure_admin_authenticated

  def new(conn, _params, current_user) do
    render(conn, "new.html",
      current_user: current_user,
      title: "Admin"
    )
  end

  def create(
        conn,
        %{"phone_number" => phone_number, "name" => name},
        _current_user
      ) do
    normalized_number =
      if Accounts.phone_number_valid?(phone_number) do
        Accounts.normalize_phone_number(phone_number)
      else
        phone_number
      end

    with {:ok, user} <-
           Accounts.get_or_create_user(phone_number: normalized_number),
         {:ok, journal} <- Content.create_user_journal(user, name) do
      conn
      |> redirect(to: Routes.admin_journal_path(conn, :show, journal.id))
    else
      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.admin_journal_path(conn, :new))
    end
  end

  def show(conn, %{"journal_id" => journal_id}, current_user) do
    case Content.get_journal(id: journal_id) do
      nil ->
        redirect(conn, to: Routes.admin_index_path(conn, :index))

      journal ->
        journal_owner_id = Content.get_journal_owner_id(journal)
        posts = Content.get_journal_posts(journal)

        render(conn, "show.html",
          current_user: current_user,
          title: "Admin",
          journal: journal,
          journal_owner_id: journal_owner_id,
          posts: posts
        )
    end
  end
end
