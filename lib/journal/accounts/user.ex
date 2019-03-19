defmodule Journal.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :last_login_at, :naive_datetime
    field :name, :string
    field :phone_number, :string
    field :phone_number_verified, :boolean
    field :verification_code, :integer

    has_many :journal_memberships, Journal.Journals.JournalMembership
    has_many :journals, through: [:journal_memberships, :journal]

    has_many :owned_journal_memberships, Journal.Journals.JournalMembership,
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
      :phone_number,
      :phone_number_verified,
      :last_login_at
    ])
    |> sanitize_name()
    |> sanitize_phone_number()
    |> validate_required([:name, :phone_number])
  end

  def sanitize_name(%Ecto.Changeset{} = changeset) do
    update_change(changeset, :name, &String.trim/1)
  end

  def sanitize_phone_number(%Ecto.Changeset{} = changeset) do
    new_phone_number = get_change(changeset, :phone_number)

    if new_phone_number == nil do
      changeset
    else
      with {:ok, phone_number} <- ExPhoneNumber.parse(new_phone_number, "US"),
           true <- ExPhoneNumber.is_valid_number?(phone_number) do
        update_change(changeset, :phone_number, fn new_phone_number ->
          {:ok, phone_number} = ExPhoneNumber.parse(new_phone_number, "US")
          ExPhoneNumber.format(phone_number, :e164)
        end)
      else
        _ ->
          add_error(changeset, :phone_number, "is invalid")
      end
    end
  end
end
