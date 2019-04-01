defmodule Quilt.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :phone_number, :string
    field :verification_code, :integer

    has_many :journal_memberships, Quilt.Content.JournalMembership
    has_many :journals, through: [:journal_memberships, :journal]

    has_many :owned_journal_memberships, Quilt.Content.JournalMembership,
      where: [type: "owner"]

    has_many :owned_journals, through: [:owned_journal_memberships, :journal]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :verification_code,
      :phone_number
    ])
    |> sanitize_name()
    |> sanitize_phone_number()
    |> validate_required([:phone_number])
    |> unique_constraint(:phone_number)
  end

  def phone_number_valid?(raw_phone_string) do
    with {:ok, phone_number} <- ExPhoneNumber.parse(raw_phone_string, "US"),
         true <- ExPhoneNumber.is_valid_number?(phone_number) do
      true
    else
      _ -> false
    end
  end

  def normalize_phone_number(raw_phone_string) do
    {:ok, phone_number} = ExPhoneNumber.parse(raw_phone_string, "US")
    ExPhoneNumber.format(phone_number, :e164)
  end

  defp sanitize_name(%Ecto.Changeset{} = changeset) do
    update_change(changeset, :name, &String.trim/1)
  end

  defp sanitize_phone_number(%Ecto.Changeset{} = changeset) do
    new_phone_number = get_change(changeset, :phone_number)

    cond do
      new_phone_number == nil ->
        changeset

      phone_number_valid?(new_phone_number) ->
        update_change(changeset, :phone_number, &normalize_phone_number/1)

      true ->
        add_error(changeset, :phone_number, "is invalid")
    end
  end
end
