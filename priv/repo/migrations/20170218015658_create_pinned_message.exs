defmodule UcxChat.Repo.Migrations.CreatePinnedMessage do
  use Ecto.Migration

  def change do
    create table(:pinned_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :message_id, references(:messages, on_delete: :delete_all, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
      # timestamps()
    end
    create index(:pinned_messages, [:message_id])
    create index(:pinned_messages, [:channel_id])
  end
end
