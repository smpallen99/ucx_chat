defmodule UcxChat.Repo.Migrations.CreateChannel do
  use Ecto.Migration

  def change do
    create table(:channels, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :topic, :string, default: ""
      add :type, :integer, default: 0, null: false
      add :read_only, :boolean, default: false, null: false
      add :archived, :boolean, default: false, null: false
      add :blocked, :boolean, default: false, null: false
      add :default, :boolean, default: false, null: false
      add :description, :text, defaut: ""
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:channels, [:user_id])
  end
end
