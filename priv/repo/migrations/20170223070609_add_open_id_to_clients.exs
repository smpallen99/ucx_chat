defmodule UcxChat.Repo.Migrations.AddOpenIdToClients do
  use Ecto.Migration

  def change do

    alter table(:clients) do
      add :open_id, references(:channels, on_delete: :delete_all)
    end

    create index(:clients, [:open_id])
  end
end
