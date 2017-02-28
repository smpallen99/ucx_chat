defmodule UcxChat.Repo.Migrations.CreateConfig do
  use Ecto.Migration

  def change do
    create table(:config) do
      add :general, :map
      add :message, :map
      add :layout, :map

      timestamps()
    end

  end
end
