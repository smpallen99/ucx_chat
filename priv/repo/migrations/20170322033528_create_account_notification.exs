defmodule UcxChat.Repo.Migrations.CreateAccountNotification do
  use Ecto.Migration

  def change do
    create table(:accounts_notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_id, references(:accounts, on_delete: :nothing, type: :binary_id)
      add :notification_id, references(:notifications, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
    create unique_index(:accounts_notifications, [:account_id, :notification_id], name: :accounts_notifications_account_id_notification_id_index)
  end
end
