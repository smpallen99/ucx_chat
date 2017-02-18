defmodule UcxChat.Repo.Migrations.CreateClient do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :nickname, :string, null: false
      add :chat_status, :string, default: "offline"
      add :tag_line, :string, default: ""
      add :uri, :string, default: ""

      timestamps(type: :utc_datetime)
      # timestamps()
    end

  end
end
