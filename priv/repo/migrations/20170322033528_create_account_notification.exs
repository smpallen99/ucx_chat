defmodule UcxChat.Repo.Migrations.CreateAccountNotification do
  use Ecto.Migration

  def change do
    create table(:accounts_notifications) do
      add :account_id, references(:accounts, on_delete: :nothing)
      add :notification_id, references(:notifications, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
    create unique_index(:accounts_notifications, [:account_id, :notification_id], name: :accounts_notifications_account_id_notification_id_index)
  end
end
