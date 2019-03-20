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
    |> cast(attrs, [:type, :name, :phone_number, :onboarding_text])
    |> set_default_type()
    |> validate_required([:type, :name])
  end

  def set_default_type(%Ecto.Changeset{} = changeset) do
    default_type = "broadcast"

    case fetch_change(changeset, :type) do
      :error -> put_change(changeset, :type, default_type)
      _ -> changeset
    end
  end
end
