defmodule Journal.Journals.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string

    belongs_to :journal, Journal.Journals.Journal
    belongs_to :user, Journal.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:content, :journal_id, :user_id])
    |> validate_required([:content, :journal_id, :user_id])
  end
end
