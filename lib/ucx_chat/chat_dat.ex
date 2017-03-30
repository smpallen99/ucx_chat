defmodule UcxChat.ChatDat do
  alias UcxChat.{Repo, Channel, User, MessageService}
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger

  defstruct user: nil, room_types: [], settings: %{}, rooms: [],
            channel: nil, messages: nil, room_map: %{}, active_room: %{},
            status: "offline", room_route: "channels", messages_info: %{},
            previews: []

  def new(user, channel, messages \\ [])
  def new(%User{roles: %Ecto.Association.NotLoaded{}} = user, %Channel{} = channel, messages) do
    user
    |> Repo.preload([:roles])
    |> new(channel, messages)
  end
  def new(%User{} = user, %Channel{} = channel, messages) do
    %{room_types: room_types, rooms: rooms, room_map: room_map, active_room: ar} =
      UcxChat.ChannelService.get_side_nav(user, channel.id)

    previews = MessageService.message_previews(user.id, messages)
    # Logger.warn "message previews: #{inspect previews}"

    status = UcxChat.PresenceAgent.get user.id
    %__MODULE__{
      status: status,
      user: user,
      room_types: room_types,
      rooms: rooms,
      room_map: room_map,
      channel: channel,
      messages: messages,
      active_room: ar,
      room_route: Channel.room_route(channel),
      previews: previews
    }
  end

  def new(%User{} = user, channel_id, messages) do
    channel = Helpers.get(Channel, channel_id)
    new(user, channel, messages)
  end
  def new(user) do
    %{room_types: room_types, rooms: rooms, room_map: room_map, active_room: _ar} =
      UcxChat.ChannelService.get_side_nav(user, nil)
    status = UcxChat.PresenceAgent.get user.id
    %__MODULE__{
      status: status,
      user: user,
      room_types: room_types,
      rooms: rooms,
      room_map: room_map,
      channel: nil,
      messages: [],
      active_room: 0,
      room_route: "home"
    }
  end

  def get_messages_info(chatd) do
    get_messages_info(chatd, chatd.user)
  end
  def get_messages_info(chatd, user) do
    case chatd.channel do
      %Channel{id: id} ->
        value = MessageService.get_messages_info(chatd.messages, id, user)
        # Logger.warn "chatd value: value: #{inspect value}"
        set(chatd, :messages_info, value)
      _ ->
        chatd
    end
  end

  def set(chatd, field, value) do
    struct chatd, [{field, value}]
  end

  def favorite_room?(%__MODULE__{} = chatd, channel_id) do
    with room_types <- chatd.rooms,
         stared when not is_nil(stared) <- Enum.find(room_types, &(&1[:type] == :stared)),
         room when not is_nil(room) <- Enum.find(stared, &(&1[:channel_id] == channel_id)) do
      true
    else
      _ -> false
    end
  end

  def get_channel_data(%__MODULE__{channel: %Channel{id: id}, room_map: map}), do: map[id]

end
