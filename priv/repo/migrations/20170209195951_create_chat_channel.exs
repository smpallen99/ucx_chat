defmodule UcxChat.Repo.Migrations.CreateChatChannel do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :private, :boolean, default: false, null: false

      timestamps()
    end

  end
end
