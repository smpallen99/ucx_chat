defmodule UcxChat.Repo.Migrations.CreateChannel do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :topic, :string, default: ""
      add :type, :integer, default: 0, null: false
      add :read_only, :boolean, default: false, null: false
      add :client_id, references(:clients, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:channels, [:client_id])
  end
end
