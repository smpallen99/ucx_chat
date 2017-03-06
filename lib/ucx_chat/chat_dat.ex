defmodule UcxChat.ChatDat do
  alias UcxChat.{Repo, Channel, User}
  alias UcxChat.ServiceHelpers, as: Helpers

  defstruct user: nil, room_types: [], settings: %{}, rooms: [],
            channel: nil, messages: nil, room_map: %{}, active_room: %{},
            status: "offline", room_route: "channels"

  def new(user, channel, messages \\ [])
  def new(%User{roles: %Ecto.Association.NotLoaded{}} = user, %Channel{} = channel, messages) do
    user
    |> Repo.preload([:roles])
    |> new(channel, messages)
  end
  def new(%User{} = user, %Channel{} = channel, messages) do
    %{room_types: room_types, rooms: rooms, room_map: room_map, active_room: ar} =
      UcxChat.ChannelService.get_side_nav(user, channel.id)
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
      room_route: Channel.room_route(channel)
    }
  end

  def new(%User{} = user, channel_id, messages) do
    channel = Helpers.get(Channel, channel_id)
    new(user, channel, messages)
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
