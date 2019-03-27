defmodule QuiltWeb.AdminView do
  use QuiltWeb, :view

  def owner_or_subscriber_class(post, journal_owner_id) do
    if post.user.id == journal_owner_id do
      "owner"
    else
      "subscriber"
    end
  end
end
