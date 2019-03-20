defmodule JournalWeb.Controllers.Helpers do
  import Plug.Conn
  import Phoenix.Controller

  alias JournalWeb.Guardian.Plug, as: Guardian
  alias JournalWeb.Router.Helpers, as: Routes

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
      redirect(conn, to: Routes.user_path(conn, :index))
    else
      conn
    end
  end

  def ensure_unauthenticated(conn, _params) do
    if get_current_user(conn) == nil do
      conn
    else
      redirect(conn, to: Routes.journal_path(conn, :index))
    end
  end

  def changeset_errors(%Ecto.Changeset{} = changeset) do
    changeset.errors
    |> Enum.map(fn {k, v} -> "#{k} #{render_detail(v)}" end)
  end

  defp render_detail({message, values}) do
    Enum.reduce(values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end)
  end

  defp render_detail(message) do
    message
  end
end
