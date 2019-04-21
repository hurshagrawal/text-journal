defmodule QuiltWeb.JournalController do
  use QuiltWeb, :controller
  use QuiltWeb.GuardedController

  alias Quilt.Content

  plug :ensure_authenticated when action in [:index, :create, :update]

  def index(conn, _params, current_user) do
    if journal = Content.get_user_journal(current_user) do
      render(conn, "index.html",
        title: "Journal Settings",
        current_user: current_user,
        show_sign_out: true,
        journal: journal
      )
    else
      render(conn, "index.html",
        journal: nil,
        current_user: current_user
      )
    end
  end

  def show(conn, %{"journal_id" => journal_id}, _current_user) do
    case Content.get_journal(id: journal_id) do
      nil ->
        redirect(conn, to: Routes.user_path(conn, :index))

      journal ->
        journal_owner_id = Content.get_journal_owner_id(journal)

        posts =
          journal
          |> Content.get_journal_posts()
          |> Enum.filter(fn post ->
            post.user_id == journal_owner_id
          end)

        render(conn, "show.html",
          journal: journal,
          posts: posts
        )
    end
  end

  def create(conn, %{"name" => name}, current_user) do
    case Content.create_user_journal(current_user, name) do
      {:ok, _} ->
        redirect(conn, to: Routes.journal_path(conn, :index))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.journal_path(conn, :index))
    end
  end

  def update(conn, params, _current_user) do
    attrs = %{
      name: params["name"],
      onboarding_text: params["onboarding_text"],
      subscriber_response_text: params["subscriber_response_text"]
    }

    Content.get_journal(id: params["id"])
    |> Content.update_journal(attrs)

    conn
    |> put_flash(:info, "Saved")
    |> redirect_to_back()
  end
end
