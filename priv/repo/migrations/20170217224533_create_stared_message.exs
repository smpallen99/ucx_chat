defmodule UcxChat.Repo.Migrations.CreateStaredMessage do
  use Ecto.Migration

  def change do
    create table(:stared_messages) do
      add :client_id, references(:clients, on_delete: :delete_all)
      add :message_id, references(:messages, on_delete: :delete_all)
      add :channel_id, references(:messages, on_delete: :delete_all)

      timestamps()
    end
    create index(:stared_messages, [:client_id])
    create index(:stared_messages, [:message_id])
    create index(:stared_messages, [:channel_id])

  end
end
