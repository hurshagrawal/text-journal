defmodule JournalWeb.JournalController do
  use JournalWeb, :controller

  alias Journal.Accounts
  alias Journal.Accounts.User
  alias Journal.Journals
  alias Journal.Journals.Journal

  def index(conn, _params, current_user) do
  end

  def update(conn, %{"journal" => journal_params}, current_user) do
  end
end
