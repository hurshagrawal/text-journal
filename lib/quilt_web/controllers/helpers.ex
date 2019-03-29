defmodule QuiltWeb.Controllers.Helpers do
  import Plug.Conn
  import Phoenix.Controller

  alias QuiltWeb.Guardian.Plug, as: Guardian
  alias QuiltWeb.Router.Helpers, as: Routes

  @admin_user_ids [1, 2, 8]

  def get_current_user(conn) do
    Guardian.current_resource(conn)
  end

  def sign_in(conn, user) do
    Guardian.sign_in(conn, user)
  end

  def sign_out(conn) do
    Guardian.sign_out(conn)
  end

  def ensure_authenticated(conn, _params) do
    if get_current_user(conn) == nil do
      conn
      |> redirect(to: Routes.user_path(conn, :index))
      |> halt()
    else
      conn
    end
  end

  def ensure_unauthenticated(conn, _params) do
    if get_current_user(conn) == nil do
      conn
    else
      conn
      |> redirect(to: Routes.journal_path(conn, :index))
      |> halt()
    end
  end

  def ensure_admin_authenticated(conn, _params) do
    with user when user != nil <- get_current_user(conn),
         true <- Enum.member?(@admin_user_ids, user.id) do
      conn
    else
      _ -> redirect(conn, to: Routes.user_path(conn, :index))
    end
  end
end
