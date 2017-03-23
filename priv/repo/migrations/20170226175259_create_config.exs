defmodule UcxChat.Repo.Migrations.CreateConfig do
  use Ecto.Migration

  def change do
    create table(:config, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :general, :map
      add :message, :map
      add :layout, :map

      timestamps()
    end

  end
end
