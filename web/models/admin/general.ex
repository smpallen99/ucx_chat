defmodule UcxChat.Config.General do
  use UcxChat.Web, :model

  @all_slash_commands [
    "join", "archive", "kick", "lennyface", "leave", "gimme", "create", "invite",
    "invite-all-to", "invite-all-from", "msg", "part", "unarchive", "tableflip",
    "topic", "mute", "me", "open", "unflip", "shrug", "unmute" ]

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
    field :enable_favorate_rooms, :boolean, default: true
    field :rooms_slash_commands, {:array, :string}, default: @rooms_slash_commands
    field :chat_slash_commands, {:array, :string}, default: @chat_slash_commands
  end

  @fields [:enable_favorate_rooms, :rooms_slash_commands, :chat_slash_commands]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

end
