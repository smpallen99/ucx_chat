defmodule UcxChat.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :text
      add :type, :string, size: 2, default: ""
      add :edited_id, references(:users, on_delete: :nilify_all)
      add :sequential, :boolean, default: false, null: false
      add :system, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nilify_all)
      add :channel_id, references(:channels, on_delete: :delete_all)
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
