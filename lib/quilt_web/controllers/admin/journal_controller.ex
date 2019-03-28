defmodule QuiltWeb.Admin.JournalController do
  use QuiltWeb, :controller
  use QuiltWeb.GuardedController

  alias Quilt.Content

  plug :ensure_admin_authenticated

  def new(conn, _params, current_user) do
    render(conn, "new.html",
      current_user: current_user,
      title: "Admin"
    )
  end

  def create(
        conn,
        %{"owner_phone_number" => owner_phone_number, "name" => name},
        current_user
      ) do
    # TODO: DRY up journal_controller#create by pushing logic into Content
    # TODO: Hook this up to create new journals
    redirect(conn,
      to: Routes.admin_index_path(conn, :show, journal_id: 1)
    )
  end

  def show(conn, %{"journal_id" => journal_id}, current_user) do
    case Content.get_journal(id: journal_id) do
      nil ->
        redirect(conn, to: Routes.admin_index_path(conn, :index))

      journal ->
        journal_owner_id = Content.get_journal_owner_id(journal)
        subscriber_count = Content.get_journal_subscribers_count(journal)
        posts = Content.get_journal_posts(journal)
        posts_count = Content.get_journal_owner_posts_count(journal)
        replies_count = Content.get_journal_replies_count(journal)

        render(conn, "show.html",
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
end
