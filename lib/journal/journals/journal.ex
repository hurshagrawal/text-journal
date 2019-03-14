defmodule Journal.Journals.Journal do
  use Ecto.Schema
  import Ecto.Changeset

  schema "journals" do
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(journal, attrs) do
    journal
    |> cast(attrs, [:type])
    |> validate_required([:type])
  end
end
