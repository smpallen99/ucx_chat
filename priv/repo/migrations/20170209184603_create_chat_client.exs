defmodule UcxChat.Repo.Migrations.CreateChatClient do
  use Ecto.Migration

  def change do
    create table(:chat_clients) do
      add :nickname, :string, null: false
      add :chat_status, :string, default: ""
      add :tag_line, :string, default: ""
      add :uri, :string, default: ""

      timestamps()
    end

  end
end
