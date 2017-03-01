defmodule UcxChat.Repo.Migrations.CreateClient do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :nickname, :string, null: false
      add :chat_status, :string
      add :tag_line, :string, default: ""
      add :uri, :string, default: ""
      add :type, :string, size: 1, default: ""

      timestamps(type: :utc_datetime)
      # timestamps()
    end

  end
end
