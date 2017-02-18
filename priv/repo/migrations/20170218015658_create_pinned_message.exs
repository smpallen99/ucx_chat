defmodule UcxChat.Repo.Migrations.CreatePinnedMessage do
  use Ecto.Migration

  def change do
    create table(:pinned_messages) do
      add :message_id, references(:messages, on_delete: :delete_all)
      add :channel_id, references(:channels, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
      # timestamps()
    end
    create index(:pinned_messages, [:message_id])
    create index(:pinned_messages, [:channel_id])
  end
end
