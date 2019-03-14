defmodule Journal.Journals do
  import Ecto.Query, warn: false
  alias Journal.Repo

  alias Journal.Accounts.User
  alias Journal.Journals.Journal
  alias Journal.Journals.Post
  alias Journal.Journals.JournalMembership
end
