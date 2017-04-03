defmodule UcxChat.Repo.Migrations.AddFileToMessages do
  use Ecto.Migration

  def change do

    alter table(:messages) do
      add :file, :string
    end
  end
end
