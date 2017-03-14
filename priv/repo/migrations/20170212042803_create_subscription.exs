defmodule UcxChat.Repo.Migrations.CreateSubscription do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :last_read, :integer, default: 0
      add :type, :integer, default: 0
      add :open, :boolean, default: false
      add :alert, :boolean, default: false
      add :hidden, :boolean, default: false
      add :has_unread, :boolean, default: false
      add :ls, :utc_datetime                     # last seen
      add :f, :boolean, default: false          # favorite
      add :unread, :integer, default: 0
      add :scroll_top, :integer, default: 0
      add :channel_id, references(:channels, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
      # timestamps()
    end
    create unique_index(:subscriptions, [:user_id, :channel_id], name: :subscriptions_user_id_channel_id_index)

  end
end
