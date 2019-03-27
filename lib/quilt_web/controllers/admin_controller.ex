defmodule QuiltWeb.AdminController do
  use QuiltWeb, :controller
  use QuiltWeb.GuardedController

  alias Quilt.{Accounts, Content, Sms}

  @admin_user_ids [1, 2, 8]

  plug :ensure_authorized

  def index(conn, _params, current_user) do
    render(conn, "index.html",
      current_user: current_user,
      title: "Admin",
      journals: Content.get_journals()
    )
  end

  def journal(conn, %{"journal_id" => journal_id}, current_user) do
    case Content.get_journal(id: journal_id) do
      nil ->
        redirect(conn, to: Routes.admin_path(conn, :index))

      journal ->
        journal_owner_id = Content.get_journal_owner_id(journal)
        subscriber_count = Content.get_journal_subscribers_count(journal)
        posts = Content.get_journal_posts(journal)
        posts_count = Content.get_journal_owner_posts_count(journal)
        replies_count = Content.get_journal_replies_count(journal)

        render(conn, "journal.html",
          current_user: current_user,
          title: "Admin",
          journal: journal,
          journal_owner_id: journal_owner_id,
          subscriber_count: subscriber_count,
          posts: posts,
          posts_count: posts_count,
          replies_count: replies_count
        )
    end
  end

  defp ensure_authorized(conn, _params) do
    with user <- get_current_user(conn),
         true <- Enum.member?(@admin_user_ids, user.id) do
      conn
    else
      _ -> redirect(conn, to: Routes.user_path(conn, :index))
    end
  end
end
