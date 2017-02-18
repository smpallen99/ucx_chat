defmodule UcxChat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :string
      add :sequential, :boolean, default: false, null: false
      add :client_id, references(:clients, on_delete: :nothing)
      add :channel_id, references(:channels, on_delete: :nothing)

      timestamps(type: :utc_datetime)
      # timestamps()
    end
    create index(:messages, [:client_id])
    create index(:messages, [:channel_id])
  end
end
