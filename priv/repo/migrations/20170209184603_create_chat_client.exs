defmodule UcxChat.Repo.Migrations.CreateClient do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :nickname, :string, null: false
      add :chat_status, :string, default: ""
      add :tag_line, :string, default: ""
      add :uri, :string, default: ""

      timestamps()
    end

  end
end
