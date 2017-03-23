defmodule UcxChat.Repo.Migrations.CreateSubscription do
  use Ecto.Migration

  def change do
    create table(:subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :last_read, :string, default: ""
      add :type, :integer, default: 0
      add :open, :boolean, default: false
      add :alert, :boolean, default: false
      add :hidden, :boolean, default: false
      add :has_unread, :boolean, default: false
      add :ls, :utc_datetime                     # last seen
      add :f, :boolean, default: false          # favorite
      add :unread, :integer, default: 0
      add :current_message, :string, default: ""
      add :channel_id, references(:channels, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps(type: :utc_datetime)
      # timestamps()
    end
    create unique_index(:subscriptions, [:user_id, :channel_id], name: :subscriptions_user_id_channel_id_index)

  end
end
