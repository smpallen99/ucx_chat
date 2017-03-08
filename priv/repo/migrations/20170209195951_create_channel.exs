defmodule UcxChat.Repo.Migrations.CreateChannel do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :topic, :string, default: ""
      add :type, :integer, default: 0, null: false
      add :read_only, :boolean, default: false, null: false
      add :archived, :boolean, default: false, null: false
      add :blocked, :boolean, default: false, null: false
      add :description, :text, defaut: ""
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:channels, [:user_id])
  end
end
