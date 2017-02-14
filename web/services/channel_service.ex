defmodule UcxChat.ChannelService do
  @moduledoc """
  Helper functions used by the controller, channel, and model for Channels
  """
  alias UcxChat.{Repo, Channel, ChannelClient, MessageService, Client, User, ChatDat}
  import Ecto.Query

  require Logger

  @public_channel  0
  @private_channel 1
  @direct_message  2
  @stared_room     3

  # def room_type(:public), do: @public_channel
  # def room_type(:private), do: @private_channel
  # def room_type(:direct), do: @direct_message
  # def room_type(:stared), do: @stared_room

  def room_type(0), do: :public
  def room_type(1), do: :private
  def room_type(2), do: :direct
  def room_type(3), do: :stared


  def room_type(:public), do: 0
  def room_type(:private), do: 1
  def room_type(:direct), do: 2
  def room_type(:stared), do: 3

  def base_types do
    [:stared, :public, :direct]
    |> Enum.map(&(%{type: &1, can_show_room: true,
      template_name: get_templ(&1), rooms: []}))
  end

  @doc """
  Get the side_nav data used in the side_nav templates
  """
  def get_side_nav(%Client{id: id}, channel_id), do: get_side_nav(id, channel_id)
  def get_side_nav(id, channel_id) do
    rooms =
      ChannelClient
      |> where([cc], cc.client_id == ^id)
      |> preload([:channel])
      |> Repo.all
      |> Enum.map(fn cc ->
        chan = cc.channel
        active = chan.id == channel_id
        type = get_chan_type(cc.type, chan.type)
        # Logger.warn "get_side_nav type: #{inspect type}, cc: #{inspect cc}"
        %{
          active: active, unread: false, alert: false, user_status: "off-line",
          unread: false, can_leave: true, archived: false, name: chan.name,
          room_icon: get_icon(type), channel_id: chan.id,
          type: type, can_leave: true
        }
      end)

    room_map = Enum.reduce rooms, %{}, fn room, acc ->
      put_in acc, [room[:channel_id]], room
    end
    types = Enum.group_by(rooms, &Map.get(&1, :type))
    room_types = Enum.reduce(types, %{}, fn {type, list}, acc ->
      map = %{
        type: type,
        can_show_room: true,  # this needs to be based on permissions
        template_name: get_templ(type),
        rooms: list,
      }
      put_in acc, [type], map
      # [map|acc]
    end)

    room_types =
      base_types()
      |> Enum.map(fn %{type: type} = bt ->
        case room_types[type] do
          nil -> bt
          other -> other
        end
      end)

    %{room_types: room_types, room_map: room_map, rooms: []}
  end

  def favorite_room?(chatd, channel_id) do
    with room_types <- chatd.rooms,
         stared when not is_nil(stared) <- Enum.find(&(&1[:type] == :stared)),
         room when not is_nil(room) <- Enum.find(stared, &(&1[:channel_id] == channel_id)) do
      true
    else
      _ -> false
    end
  end

  def get_chan_type(3, _), do: :stared
  def get_chan_type(_, type), do: room_type(type)

  def open_room(client_id, room, old_room) do
    Logger.debug "open_room client_id: #{inspect client_id}, room: #{inspect room}, old_room: #{inspect old_room}"
    client =
      Client
      |> where([c], c.id == ^client_id)
      |> Repo.one!

    channel =
      Channel
      |> where([c], c.name == ^room)
      |> Repo.one!

    messages = MessageService.get_messages(channel.id)
    chatd = ChatDat.new client, channel, messages
    box_html =
      "messages_box.html"
      |> UcxChat.MasterView.render(chatd: chatd)
      |> Phoenix.HTML.safe_to_string

    header_html =
      "messages_header.html"
      |> UcxChat.MasterView.render(chatd: chatd)
      |> Phoenix.HTML.safe_to_string
    %{
      room_title: room,
      channel_id: channel.id,
      box_html: box_html,
      header_html: header_html
    }
  end

  def toggle_favorite(client_id, channel_id) do
    cc =
      ChannelClient
      |> where([c], c.client_id == ^client_id and c.channel_id == ^channel_id)
      |> preload([:channel, :client])
      |> Repo.one!
    cc_type = if cc.type == room_type(:stared) do
      # change it back
      cc.channel.type
    else
      # star it
      room_type(:stared)
    end
    ChannelClient.changeset(cc, %{type: cc_type}) |> Repo.update!
    chatd = ChatDat.new cc.client, cc.channel, []
    messages_html =
      "messages_header.html"
      |> UcxChat.MasterView.render(chatd: chatd)
      |> Phoenix.HTML.safe_to_string

    side_nav_html =
      "rooms_list.html"
      |> UcxChat.SideNavView.render(chatd: chatd)
      |> Phoenix.HTML.safe_to_string

    {:ok, %{messages_html: messages_html, side_nav_html: side_nav_html}}
  end

  def get_templ(:stared), do: "stared_rooms.html"
  def get_templ(:direct), do: "direct_messages.html"
  def get_templ(_), do: "channels.html"

  def get_icon(:public), do: "icon-hash"
  def get_icon(:private), do: "icon-hash"
  def get_icon(:stared), do: "icon-hash"
  def get_icon(:direct), do: "icon-at"


  # def get_route(@stared_room, name), do: "/direct/" <> name
  # def get_route(@direct_message, name), do: "/direct/" <> name
  # def get_route(_, name), do: "/channel/" <> name
end
