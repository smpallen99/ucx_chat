defmodule UcxChat.Repo.Migrations.CreateUsersRoles do
  use Ecto.Migration

  def change do
    create table(:users_roles) do
      add :role, :string, null: false
      add :scope, :integer, default: 0
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
    create index(:users_roles, [:user_id])

  end
end
