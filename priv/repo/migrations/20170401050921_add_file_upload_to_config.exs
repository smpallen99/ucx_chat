defmodule UcxChat.Repo.Migrations.AddFileUploadToConfig do
  use Ecto.Migration

  def change do
    alter table(:config) do
      add :file_upload, :map
    end
  end
end
