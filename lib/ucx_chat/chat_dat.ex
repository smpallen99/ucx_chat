defmodule UcxChat.ChatDat do
  alias UcxChat.{Client, Channel}

  defstruct room_types: [], settings: %{}, rooms: [], client: nil, channel: nil, messages: nil, room_map: %{}, active_room: %{}

  def new(client, channel, messages \\ [])
  def new(%Client{} = client, %Channel{} = channel, messages) do
    %{room_types: room_types, rooms: rooms, room_map: room_map, active_room: ar} =
      UcxChat.ChannelService.get_side_nav(client, channel.id)
    %__MODULE__{room_types: room_types, rooms: rooms, room_map: room_map,  channel: channel, messages: messages, client: client, active_room: ar}
  end

  def new(%Client{} = client, channel_id, messages) do
    %{room_types: room_types, rooms: rooms, room_map: room_map, active_room: ar} =
      UcxChat.ChannelService.get_side_nav(client, channel_id)
    %__MODULE__{room_types: room_types, rooms: rooms, room_map: room_map, messages: messages, active_room: ar}
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
