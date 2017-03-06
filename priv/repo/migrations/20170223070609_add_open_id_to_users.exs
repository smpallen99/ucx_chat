defmodule UcxChat.Repo.Migrations.AddOpenIdToUsers do
  use Ecto.Migration

  def change do

    alter table(:users) do
      add :open_id, references(:channels, on_delete: :delete_all)
    end

    create index(:users, [:open_id])
  end
end
