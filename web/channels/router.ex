defmodule UcxChat.ChannelRouter do
  use ChannelRouter

  # @module __MODULE__

  def match(:post, socket, ["typing"], params) do
    # module and action are build by the post macro
    apply(UcxChat.TypingChannelController, :create, [socket, params])
  end

  def match(:delete, socket, ["typing"], params) do
    apply(UcxChat.TypingChannelController, :delete, [socket, params])
  end

  def match(:put, socket, ["slashcommand", command], params) do
    params = Map.put(params, "command", command)
    apply(UcxChat.SlashCommandChannelController, :execute, [socket, params])
  end

  # get "/room/:room_id", RoomChannelController, :show
  # put "/room/favorite", RoomChannelController, :favorite

  def match(:delete, socket, ["room", room], params) do
    params = Map.put(params, "room", room)
    apply(UcxChat.RoomChannelController, :delete, [socket, params])
  end
  def match(:get, socket, ["room", room_id], params) do
    params = Map.put(params, "room_id", room_id)
    apply(UcxChat.RoomChannelController, :show, [socket, params])
  end

  def match(:put, socket, ["room", "favorite"], params) do
    apply(UcxChat.RoomChannelController, :favorite, [socket, params])
  end

  def match(:put, socket, ["room", "hide", room], params) do
    params = Map.put(params, "room", room)
    apply(UcxChat.RoomChannelController, :hide, [socket, params])
  end

  def match(:put, socket, ["room", "leave", room], params) do
    params = Map.put(params, "room", room)
    apply(UcxChat.RoomChannelController, :leave, [socket, params])
  end

  def match(:put, socket, ["room", command, username], params) do
    params =
      [{"command", command}, {"username", username}]
      |> Enum.into(params)
    apply(UcxChat.RoomChannelController, :command, [socket, params])
  end

  # post "/direct/:username", DirectMessageChannelController, :create
  # post "/direct/:username", RoomChannelController, :create

  def match(:put, socket, ["direct", username], params) do
    params = Map.put(params, "username", username)
    apply(UcxChat.RoomChannelController, :create, [socket, params])
  end

  def match(:post, socket, ["messages"], params) do
    apply(UcxChat.MessageChannelController, :create, [socket, params])
  end

  def match(:get, socket, ["messages", "surrounding"], params) do
    apply(UcxChat.MessageChannelController, :surrounding, [socket, params])
  end
  def match(:get, socket, ["messages", "last"], params) do
    apply(UcxChat.MessageChannelController, :last, [socket, params])
  end
  def match(:get, socket, ["messages", "previous"], params) do
    apply(UcxChat.MessageChannelController, :previous, [socket, params])
  end
  def match(:get, socket, ["messages"], params) do
    apply(UcxChat.MessageChannelController, :index, [socket, params])
  end
  def match(:put, socket, ["messages", message_id], params) do
    params = Map.put(params, "id", message_id)
    apply(UcxChat.MessageChannelController, :update, [socket, params])
  end

  def match(:get, socket, ["room_settings", field_name], params) do
    params = Map.put(params, "field_name", field_name)
    apply(UcxChat.RoomSettingChannelController, :edit, [socket, params])
  end

  def match(:get, socket, ["room_settings", field_name, "cancel"], params) do
    params = Map.put(params, "field_name", field_name)
    apply(UcxChat.RoomSettingChannelController, :cancel, [socket, params])
  end

  def match(:put, socket, ["room_settings", field_name], params) do
    params = Map.put(params, "field_name", field_name)
    apply(UcxChat.RoomSettingChannelController, :update, [socket, params])
  end

end
