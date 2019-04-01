defmodule QuiltWeb.SharedView do
  use QuiltWeb, :view

  alias Quilt.Content

  defdelegate subscriber_count(journal),
    to: Content,
    as: :get_journal_subscribers_count

  defdelegate unsubscribed_count(journal),
    to: Content,
    as: :get_journal_unsubscribed_count

  defdelegate posts_count(journal),
    to: Content,
    as: :get_journal_owner_posts_count

  defdelegate replies_count(journal),
    to: Content,
    as: :get_journal_replies_count
end
