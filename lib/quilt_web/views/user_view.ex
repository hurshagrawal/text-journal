defmodule QuiltWeb.UserView do
  use QuiltWeb, :view

  def render("error.json", %{message: message}) do
    %{message: message}
  end
end
