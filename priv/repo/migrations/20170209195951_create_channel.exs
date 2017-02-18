defmodule UcxChat.Repo.Migrations.CreateChannel do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :topic, :string, default: ""
      add :type, :integer, default: 0, null: false
      add :read_only, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
      # timestamps()
    end

  end
end
