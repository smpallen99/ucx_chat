defmodule UcxChat.Repo.Migrations.CreateMute do
  use Ecto.Migration

  def change do
    create table(:muted) do
      add :client_id, references(:clients, on_delete: :delete_all)
      add :channel_id, references(:channels, on_delete: :delete_all)

      timestamps()
    end
    # create index(:muted, [:client_id])
    # create index(:muted, [:channel_id])
    create unique_index(:muted, [:client_id, :channel_id], name: :muted_client_id_channel_id_index)

  end
end
