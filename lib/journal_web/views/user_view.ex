defmodule JournalWeb.UserView do
  use JournalWeb, :view

  def render("error.json", %{message: message}) do
    %{message: message}
  end
end
