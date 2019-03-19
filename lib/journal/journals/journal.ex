defmodule Journal.Journals.Journal do
  use Ecto.Schema
  import Ecto.Changeset

  schema "journals" do
    field :type, :string
    field :phone_number, :string
    field :name, :string
    field :onboarding_text, :string

    has_many :journal_memberships, Journal.Journals.JournalMembership
    has_many :users, through: [:journal_memberships, :user]

    has_many :owner_journal_memberships, Journal.Journals.JournalMembership,
      where: [type: "owner"]

    has_many :owners,
      through: [:owner_journal_memberships, :user]

    has_many :posts, Journal.Journals.Post

    timestamps()
  end

  @doc false
  def changeset(journal, attrs) do
    journal
    |> cast(attrs, [:type])
    |> validate_required([:type])
  end
end
