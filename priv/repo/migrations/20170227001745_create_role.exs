defmodule UcxChat.Repo.Migrations.CreateRole do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :name, :string, primary_key: true
      add :scope, :string, default: "global"
      add :description, :string

      timestamps()
    end

    create unique_index(:roles, [:name])
  end
end
