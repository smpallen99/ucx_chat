defmodule UcxChat.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :language, :string, default: "en"
      add :desktop_notification_enabled, :boolean, default: true, null: false
      add :desktop_notification_duration, :integer
      add :unread_alert, :boolean, default: true, null: false
      add :use_emojis, :boolean, default: true, null: false
      add :convert_ascii_emoji, :boolean, default: true, null: false
      add :auto_image_load, :boolean, default: true, null: false
      add :save_mobile_bandwidth, :boolean, default: true, null: false
      add :collapse_media_by_default, :boolean, default: false, null: false
      add :unread_rooms_mode, :boolean, default: false, null: false
      add :hide_user_names, :boolean, default: false, null: false
      add :hide_flex_tab, :boolean, default: false, null: false
      add :hide_avatars, :boolean, default: false, null: false
      add :merge_channels, :boolean, default: nil, null: true
      add :enter_key_behaviour, :string, default: "normal"
      add :view_mode, :integer, default: 1
      add :email_notification_mode, :string, default: "all"
      add :highlights, :text, default: ""
      add :new_room_notification, :string, default: "door"
      add :new_message_notification, :string, default: "chime"
      add :chat_mode, :boolean, default: false, null: false
      add :enable_desktop_notifications, :boolean, default: true, null: false

      timestamps()
    end

  end
end
