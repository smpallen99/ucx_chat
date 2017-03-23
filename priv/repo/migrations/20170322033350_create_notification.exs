defmodule UcxChat.Repo.Migrations.CreateNotification do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :settings, :map
      add :channel_id, references(:channels, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:channel_id])

  end
end
