defmodule Quilt.Repo.Migrations.AddSubscriberResponseSentToMemberships do
  use Ecto.Migration

  def change do
    alter table(:journal_memberships) do
      add(:subscriber_response_sent, :boolean, null: false, default: false)
    end
  end
end
