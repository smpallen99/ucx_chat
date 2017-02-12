defmodule UcxChat.Repo.Migrations.CreateChannelClient do
  use Ecto.Migration

  def change do
    create table(:channels_clients) do
      add :channel_id, references(:channels, on_delete: :delete_all)
      add :client_id, references(:clients, on_delete: :delete_all)

      timestamps()
    end
    create index(:channels_clients, [:channel_id])
    create index(:channels_clients, [:client_id])

  end
end
