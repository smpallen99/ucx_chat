defmodule UcxChat.Repo.Migrations.CreateUsersRoles do
  use Ecto.Migration

  def change do
    create table(:users_roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string, null: false
      add :scope, :binary_id, default: nil
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end
    create index(:users_roles, [:user_id])
    create index(:users_roles, [:scope])

  end
end
