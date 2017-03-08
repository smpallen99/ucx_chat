defmodule UcxChat.Repo.Migrations.CreateStaredMessage do
  use Ecto.Migration

  def change do
    create table(:stared_messages) do
      add :user_id, references(:users, on_delete: :nilify_all)
      add :message_id, references(:messages, on_delete: :delete_all)
      add :channel_id, references(:channels, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
      # timestamps()
    end
    create index(:stared_messages, [:user_id])
    create index(:stared_messages, [:message_id])
    create index(:stared_messages, [:channel_id])

  end
end
