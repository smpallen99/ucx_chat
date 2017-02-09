defmodule UcxChat.Repo.Migrations.CreateCoherenceUser do
  use Ecto.Migration
  def change do
    create table(:chat_users) do
      add :name, :string
      add :email, :string

      add :username, :string
      add :chat_status, :string
      add :tag_line, :string
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

      timestamps()
    end
    create unique_index(:chat_users, [:username])

  end
end
