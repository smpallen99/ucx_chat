defmodule UcxChat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :string
      add :client_id, references(:chat_clients, on_delete: :nothing)
      add :channel_id, references(:channels, on_delete: :nothing)

      timestamps()
    end
    create index(:messages, [:client_id])
    create index(:messages, [:channel_id])
  end
end
