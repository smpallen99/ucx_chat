defmodule UcxChat.Repo.Migrations.CreateAttachments do
  use Ecto.Migration

  def change do
    create table(:attachments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :file, :string
      add :file_name, :string, default: ""
      add :description, :string, default: ""
      add :type, :string, default: ""
      add :size, :integer, default: 0
      add :channel_id, references(:channels, on_delete: :delete_all, type: :binary_id)
      add :message_id, references(:messages, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
    create index(:attachments, [:channel_id])
    create index(:attachments, [:message_id])

  end
end
