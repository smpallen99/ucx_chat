defmodule UcxChat.Config.General do
  use UcxChat.Web, :model

  @all_slash_commands [
    "join", "archive", "kick", "lennyface", "leave", "gimme", "create", "invite",
    "invite-all-to", "invite-all-from", "msg", "part", "unarchive", "tableflip",
    "topic", "mute", "me", "open", "unflip", "shrug", "unmute", "unhide" ]

  @rooms_slash_commands @all_slash_commands

  @chat_slash_commands [
    "lennyface", "gimme", "msg", "tableflip", "mute", "me", "unflip", "shrug", "unmute" ]


  # defstruct enable_favorate_rooms: true,
  #           rooms_slash_commands: @rooms_slash_commands,
  #           chat_slash_commands: @chat_slash_commands


  # embedded_schema is short for:
  #
  #   @primary_key {:id, :binary_id, autogenerate: true}
  #   schema "embedded Item" do
  #
  embedded_schema do
    field :site_url, :string, default: "change-this"
    field :site_name, :string, default: "UcxChat"
    field :enable_favorite_rooms, :boolean, default: true
    field :enable_desktop_notifications, :boolean, default: true
    field :desktop_notification_duration, :integer, default: 5
    field :rooms_slash_commands, {:array, :string}, default: @rooms_slash_commands
    field :chat_slash_commands, {:array, :string}, default: @chat_slash_commands
  end

  @fields [
    :site_url, :site_name,
    :enable_favorite_rooms, :rooms_slash_commands, :chat_slash_commands,
    :enable_desktop_notifications, :desktop_notification_duration
  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

end
