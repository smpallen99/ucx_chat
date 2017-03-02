defmodule UcxChat.Repo.Migrations.CreateCoherenceUser do
  use Ecto.Migration
  def change do
    create table(:users) do
      add :name, :string
      add :email, :string

      add :username, :string
      add :admin, :boolean, default: false
      add :tz_offset, :integer

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
      # trackable
      add :sign_in_count, :integer, default: 0
      add :current_sign_in_at, :utc_datetime
      add :last_sign_in_at, :utc_datetime
      add :current_sign_in_ip, :string
      add :last_sign_in_ip, :string

      add :client_id, references(:clients, on_delete: :delete_all)

      add :account_id, references(:accounts, on_delete: :delete_all)

      timestamps()
    end
    create unique_index(:users, [:username])
    create index(:users, [:client_id])
    create index(:users, [:account_id])
  end
end
