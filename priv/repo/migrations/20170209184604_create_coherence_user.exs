defmodule UcxChat.Repo.Migrations.CreateCoherenceUser do
  use Ecto.Migration
  def change do
    create table(:chat_users) do
      add :name, :string
      add :email, :string

      add :username, :string
      add :admin, :boolean, default: false

      # unlockable_with_token
      add :unlock_token, :string
      # recoverable
      add :reset_password_token, :string
      add :reset_password_sent_at, :utc_datetime
      # lockable
      add :failed_attempts, :integer, default: 0
      add :locked_at, :utc_datetime
      # authenticatable
      add :password_hash, :string

      add :client_id, references(:chat_clients, on_delete: :delete_all)

      timestamps()
    end
    create unique_index(:chat_users, [:username])
    create index(:chat_users, [:client_id])
  end
end
