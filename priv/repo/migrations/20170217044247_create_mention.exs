defmodule UcxChat.Repo.Migrations.CreateMention do
  use Ecto.Migration

  def change do
    create table(:mentions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :unread, :boolean, default: true
      add :all, :boolean, default: true
      add :name, :string
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)
      add :message_id, references(:messages, on_delete: :nilify_all, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nilify_all, type: :binary_id)

      timestamps(type: :utc_datetime)
      # timestamps()
    end
    create index(:mentions, [:user_id])
    create index(:mentions, [:message_id])
    create index(:mentions, [:channel_id])

  end
end
