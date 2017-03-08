defmodule UcxChat.Repo.Migrations.CreateDirect do
  use Ecto.Migration

  def change do
    create table(:directs) do
      add :users, :string
      add :user_id, references(:users, on_delete: :nilify_all)
      add :channel_id, references(:channels, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
      # timestamps()
    end
    # create index(:directs, [:users])
    create unique_index(:directs, [:user_id, :users], name: :directs_user_id_users_index)
    create index(:directs, [:channel_id])

  end
end
