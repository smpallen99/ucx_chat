defmodule UcxChat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :string
      add :type, :string, size: 2, default: ""
      add :edited_id, references(:clients, on_delete: :nothing)
      add :sequential, :boolean, default: false, null: false
      add :system, :boolean, default: false, null: false
      add :client_id, references(:clients, on_delete: :nothing)
      add :channel_id, references(:channels, on_delete: :nothing)
      add :expire_at, :utc_datetime

      timestamps(type: :utc_datetime)
      # timestamps()
    end
    create index(:messages, [:client_id])
    create index(:messages, [:channel_id])
    create index(:messages, [:edited_id])
  end
end
