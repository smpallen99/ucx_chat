defmodule UcxChat.Repo.Migrations.CreateUpload do
  use Ecto.Migration

  def change do
    create table(:upload, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :file, :string
      add :name, :string, default: ""
      add :description, :string, default: ""
      add :type, :string, default: ""
      add :size, :integer, default: 0
      add :channel_id, references(:channels, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
    create index(:upload, [:channel_id])
    create index(:upload, [:user_id])

  end
end
