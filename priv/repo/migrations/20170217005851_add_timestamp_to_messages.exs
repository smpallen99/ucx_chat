defmodule UcxChat.Repo.Migrations.AddTimestampToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :timestamp, :string
    end
    create index(:messages, [:timestamp])
  end

  # def up do
  #   execute "ALTER TABLE messages ADD COLUMN timestamp BIGINT;"
  # end
  # def down do
  #   execute "ALTER TABLE messages DROP COLUMN timestamp;"
  # end
end
