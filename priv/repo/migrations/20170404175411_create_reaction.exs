defmodule UcxChat.Repo.Migrations.CreateReaction do
  use Ecto.Migration

  def change do
    create table(:reactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :emoji, :string
      add :count, :integer, default: 1
      add :user_ids, :text
      add :message_id, references(:messages, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
    create index(:reactions, [:message_id])
    create index(:reactions, [:emoji])

  end
end
