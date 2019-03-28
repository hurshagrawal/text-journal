defmodule QuiltWeb.Admin.IndexController do
  use QuiltWeb, :controller
  use QuiltWeb.GuardedController

  alias Quilt.Content

  plug :ensure_admin_authenticated

  def index(conn, _params, current_user) do
    render(conn, "index.html",
      current_user: current_user,
      title: "Admin",
      journals: Content.get_journals()
    )
  end
end
