defmodule UcxChat.Repo.Migrations.CreateCoherenceUser do
  use Ecto.Migration
  def change do
    create table(:users) do
      add :name, :string
      add :email, :string

      add :username, :string
      add :alias, :string
      add :avatar_url, :string

      # add :admin, :boolean, default: false

      add :tz_offset, :integer

      add :account_id, references(:accounts, on_delete: :delete_all)

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

      add :active, :boolean, default: true
      add :chat_status, :string
      add :tag_line, :string, default: ""
      add :uri, :string, default: ""

      timestamps(type: :utc_datetime)
    end
    create unique_index(:users, [:username])
    create unique_index(:users, [:alias])
    create index(:users, [:account_id])
  end
end
