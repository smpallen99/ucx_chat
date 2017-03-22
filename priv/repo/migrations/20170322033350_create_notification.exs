defmodule UcxChat.Repo.Migrations.CreateNotification do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :settings, :map
      add :channel_id, references(:channels, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:channel_id])

  end
end
