defmodule QuiltWeb.JournalController do
  use QuiltWeb, :controller
  use QuiltWeb.GuardedController

  alias Quilt.Content

  plug :ensure_authenticated

  def index(conn, _params, current_user) do
    if journal = Content.get_user_journal(current_user) do
      subscriber_count = Content.get_journal_subscribers_count(journal)
      posts_count = Content.get_journal_owner_posts_count(journal)
      replies_count = Content.get_journal_replies_count(journal)

      render(conn, "index.html",
        title: "Journal Settings",
        current_user: current_user,
        show_sign_out: true,
        journal: journal,
        subscriber_count: subscriber_count,
        posts_count: posts_count,
        replies_count: replies_count
      )
    else
      render(conn, "index.html",
        journal: nil,
        current_user: current_user
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
