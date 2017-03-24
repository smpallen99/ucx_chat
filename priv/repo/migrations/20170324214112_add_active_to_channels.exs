defmodule UcxChat.Repo.Migrations.AddActiveToChannels do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add :active, :boolean, default: true, null: false
    end

  end
end
