defmodule UcxChat.Repo.Migrations.CreateDirect do
  use Ecto.Migration

  def change do
    create table(:directs) do
      add :clients, :string
      add :client_id, references(:clients, on_delete: :nothing)
      add :channel_id, references(:channels, on_delete: :nothing)

      timestamps()
    end
    # create index(:directs, [:users])
    create unique_index(:directs, [:client_id, :clients], name: :directs_client_id_users_index)
    create index(:directs, [:channel_id])

  end
end
