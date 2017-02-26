defmodule UcxChat.AccountTest do
  use UcxChat.ModelCase

  alias UcxChat.Account

  # @valid_attrs %{auto_image_load: true, chat_mode: true, collapse_media_by_default: true, convert_ascii_emoji: true, desktop_notification_duration: 42, desktop_notification_enabled: true, email_notification_mode: "some content", hide_avatars: true, hide_flex_tab: true, hide_user_names: true, highlights: "some content", language: "some content", merge_channels: true, new_message_notification: "some content", new_room_notification: "some content", save_mobile_bandwidth: true, unread_alert: true, unread_rooms_mode: true, use_emojis: true, view_mode: 42}
  @valid_attrs %{}
  # @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Account.changeset(%Account{}, @valid_attrs)
    assert changeset.valid?
  end

  # test "changeset with invalid attributes" do
  #   changeset = Account.changeset(%Account{}, @invalid_attrs)
  #   refute changeset.valid?
  # end
end
