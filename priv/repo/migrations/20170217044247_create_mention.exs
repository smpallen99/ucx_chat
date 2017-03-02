defmodule UcxChat.Repo.Migrations.CreateMention do
  use Ecto.Migration

  def change do
    create table(:mentions) do
      add :unread, :boolean, default: true
      add :user_id, references(:users, on_delete: :delete_all)
      add :message_id, references(:messages, on_delete: :delete_all)
      add :channel_id, references(:channels, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
      # timestamps()
    end
    create index(:mentions, [:user_id])
    create index(:mentions, [:message_id])
    create index(:mentions, [:channel_id])

  end
end
