defmodule QuiltWeb.Admin.JournalView do
  use QuiltWeb, :view

  def owner_or_subscriber_class(post, journal_owner_id) do
    if post.user.id == journal_owner_id do
      "owner"
    else
      "subscriber"
    end
  end

  def subscribe_post_class(posts, post, journal_owner_id) do
    author_id = post.user_id
    first_author_post = Enum.find(posts, &(&1.user_id == author_id))

    if author_id != journal_owner_id && first_author_post &&
         first_author_post.id == post.id do
      "faded"
    else
      ""
    end
  end
end
