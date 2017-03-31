defmodule UcxChat.Repo.Migrations.AddEmojiFieldsToAccounts do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :emoji_category, :string, default: "people", null: false
      add :emoji_tone, :integer, default: 0, null: false
      add :emoji_recent, :text, default: "", null: false
    end
  end
end
