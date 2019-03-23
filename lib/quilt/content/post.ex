defmodule Quilt.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "posts" do
    field :body, :string
    field :media_urls, {:array, :string}

    belongs_to :journal, Quilt.Content.Journal
    belongs_to :user, Quilt.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :journal_id, :user_id, :media_urls])
    |> validate_required([:journal_id, :user_id, :media_urls])
  end

  def with_user_id(query, included_id) do
    from p in query, where: p.user_id == ^included_id
  end

  def without_user_id(query, excluded_id) do
    from p in query, where: p.user_id != ^excluded_id
  end
end
