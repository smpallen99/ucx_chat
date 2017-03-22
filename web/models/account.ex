defmodule UcxChat.Account do
  use UcxChat.Web, :model

  schema "accounts" do
    field :language, :string, default: "on"
    field :desktop_notification_enabled, :boolean, default: true
    field :desktop_notification_duration, :integer
    field :unread_alert, :boolean, default: true
    field :use_emojis, :boolean, default: true
    field :convert_ascii_emoji, :boolean, default: true
    field :auto_image_load, :boolean, default: true
    field :save_mobile_bandwidth, :boolean, default: true
    field :collapse_media_by_default, :boolean, default: false
    field :unread_rooms_mode, :boolean, default: false
    field :hide_user_names, :boolean, default: false
    field :hide_flex_tab, :boolean, default: false
    field :hide_avatars, :boolean, default: false
    field :merge_channels, :boolean, default: nil
    field :enter_key_behaviour, :string, default: "normal"
    field :view_mode, :integer, default: 1
    field :email_notification_mode, :string, default: "all"
    field :highlights, :string, default: ""
    field :new_room_notification, :string, default: "door"
    field :new_message_notification, :string, default: "chime"
    field :chat_mode, :boolean, default: false

    has_one :user, UcxChat.User, on_delete: :delete_all
    many_to_many :notifications, UcxChat.Notification, join_through: UcxChat.AccountNotification

    timestamps()
  end

  @fields [:language, :desktop_notification_enabled, :desktop_notification_duration] ++
          [:unread_alert, :use_emojis, :convert_ascii_emoji, :auto_image_load] ++
          [:save_mobile_bandwidth, :collapse_media_by_default, :unread_rooms_mode] ++
          [:hide_user_names, :hide_flex_tab, :hide_avatars, :merge_channels, :view_mode] ++
          [:email_notification_mode, :highlights, :new_room_notification] ++
          [:new_message_notification, :chat_mode]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required([])
  end

end
