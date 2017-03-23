defmodule UcxChat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :text
      add :type, :string, size: 2, default: ""
      add :edited_id, references(:users, on_delete: :nilify_all, type: :binary_id)
      add :sequential, :boolean, default: false, null: false
      add :system, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :delete_all, type: :binary_id)
      add :expire_at, :utc_datetime
      add :timestamp, :string

      timestamps(type: :utc_datetime)
      # timestamps()
    end
    create index(:messages, [:timestamp])
    create index(:messages, [:user_id])
    create index(:messages, [:channel_id])
    create index(:messages, [:edited_id])
  end
end
