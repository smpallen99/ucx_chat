defmodule UcxChat.ChannelService do
  @moduledoc """
  Helper functions used by the controller, channel, and model for Channels
  """
  alias UcxChat.{Repo, Channel, Subscription, MessageService, Client, ChatDat, Direct, Mute}
  alias UcxChat.ServiceHelpers, as: Helpers

  import Phoenix.HTML.Tag, only: [content_tag: 3, content_tag: 2]

  import Ecto.Query

  require Logger
  require IEx

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
      Subscription
      |> where([cc], cc.client_id == ^id)
      |> preload([:channel])
      |> Repo.all
      # |> Enum.reject(&(&1.channel.archived))
      |> Enum.map(fn cc ->
        chan = cc.channel
        active = chan.id == channel_id
        type = get_chan_type(cc.type, chan.type)
        display_name = get_channel_display_name(type, chan, id)
        unread = if cc.unread == 0, do: false, else: cc.unread
        # Logger.warn "get_side_nav type: #{inspect type}, display_name: #{inspect display_name}"
        # IEx.pry
        %{
          active: active, unread: unread, alert: cc.alert, user_status: "off-line",
          can_leave: true, archived: false, name: chan.name,
          room_icon: get_icon(type), channel_id: chan.id,
          type: type, can_leave: true, display_name: display_name
        }
      end)

    active_room = Enum.find(rooms, &(&1[:active]))
    Logger.debug "get_side_nav active_room: #{inspect active_room}"

    room_map = Enum.reduce rooms, %{}, fn room, acc ->
      put_in acc, [room[:channel_id]], room
    end
    types = Enum.group_by(rooms, &Map.get(&1, :type))
    # Logger.warn "get_side_nav types: #{inspect types}"
    # IEx.pry
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

    # IEx.pry

    # Logger.warn "get_side_nav room_types 1: #{inspect room_types}"
    room_types =
      base_types()
      |> Enum.map(fn %{type: type} = bt ->
        case room_types[type] do
          nil -> bt
          other -> other
        end
      end)

    # IEx.pry
    # Logger.warn "get_side_nav room_types 2: #{inspect room_types}"

    %{room_types: room_types, room_map: room_map, rooms: [], active_room: active_room}
  end

  def get_channel_display_name(type, %Channel{id: id, name: name}, client_id) when type == :direct or type == :stared do
    Direct
    |> where([d], d.channel_id == ^id and d.client_id == ^client_id)
    |> Repo.one
    |> case do
      %{} = direct -> Map.get(direct, :clients)
      _ ->  name
    end
  end
  def get_channel_display_name(_, %Channel{name: name}, _), do: name

  def favorite_room?(chatd, channel_id) do
    with room_types <- chatd.rooms,
         stared when not is_nil(stared) <- Enum.find(room_types, &(&1[:type] == :stared)),
         room when not is_nil(room) <- Enum.find(stared, &(&1[:channel_id] == channel_id)) do
      true
    else
      _ -> false
    end
  end

  def get_chan_type(3, _), do: :stared
  def get_chan_type(_, type), do: room_type(type)

  def open_room(client_id, room, old_room, display_name) do
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
      display_name: display_name,
      room_title: room,
      channel_id: channel.id,
      box_html: box_html,
      header_html: header_html
    }
  end

  def toggle_favorite(client_id, channel_id) do
    cc = Helpers.get_channel_client(channel_id, client_id, preload: [:channel, :client])
    cc_type = if cc.type == room_type(:stared) do
      # change it back
      cc.channel.type
    else
      # star it
      room_type(:stared)
    end
    Subscription.changeset(cc, %{type: cc_type}) |> Repo.update!
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

  def add_direct(nickname, client_id, channel_id) do
    client_orig = Helpers.get(Client, client_id)
    client_dest = Helpers.get_by(Client, :nickname, nickname)

    name = client_orig.nickname <> "__" <> nickname
    channel = case Helpers.get_by(Channel, :name, name) do
      %Channel{} = channel ->
        channel
      _ ->
        do_add_direct(name, client_orig, client_dest, channel_id)
    end

    chatd = ChatDat.new client_orig, channel, []

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

  defp do_add_direct(name, client_orig, client_dest, channel_id) do
    # create the channel
    channel =
      %Channel{}
      |> Channel.changeset(%{client_id: client_orig.id, name: name, type: room_type(:direct)})
      |> Repo.insert!

    # Create the cc's, and the directs one for each user
    client_names = %{client_orig.id => client_dest.nickname, client_dest.id => client_orig.nickname}

    for client <- [client_orig, client_dest] do
      %Subscription{}
      |> Subscription.changeset(%{channel_id: channel.id, client_id: client.id, type: room_type(:direct)})
      |> Repo.insert!
      %Direct{}
      |> Direct.changeset(%{clients: client_names[client.id], client_id: client.id, channel_id: channel.id})
      |> Repo.insert!
    end
    channel
  end

  # def change_type(channel_id, type) do

  # end
  ###################
  # channel commands

  def channel_command(:create, name, client_id, channel_id) do
    if Helpers.get_by(Channel, :name, name) do
      Helpers.response_message(channel_id, text: "The channel ", code: "#" <> name, text: " already exists.")
    else
      %Channel{}
      |> Channel.changeset(%{name: name, client_id: client_id})
      |> Repo.insert
      |>case do
        {:ok, channel} ->
          channel_command(:join, channel, client_id, channel_id)

          tag = content_tag :span, style: "color: green;" do
            "Channel created successfully"
          end
          Helpers.response_message(channel_id, tag: tag)

        {:error, _} ->
          Helpers.response_message(channel_id, text: "There was a problem creating ", code: "#" <> name, text: " channel.")
      end
    end
  end

  @channel_commands ~w(join leave open archive unarchive invite_all_to invite_all_from)a

  def channel_command(command, name, client_id, channel_id) when command in @channel_commands and is_binary(name) do
    case Helpers.get_by(Channel, :name, name) do
      nil ->
        Helpers.response_message(channel_id, text: "The channel ", code: "#" <> name, text: " does not exists")
      channel ->
        channel_command(command, channel, client_id, channel_id)
    end
  end

  def channel_command(:join, %Channel{} = channel, client_id, channel_id) do
    %Subscription{}
    |> Subscription.changeset(%{client_id: client_id, channel_id: channel.id})
    |> Repo.insert
    |> case do
      {:ok, subs} ->
        Helpers.response_message(channel_id, text: "You have joined the", code: channel.name, text: " channel.")
      {:error, _} ->
        Helpers.response_message(channel_id, text: "Problem joining ", code: channel.name, text: " channel.")
    end
  end

  def channel_command(:leave, %Channel{} = channel, client_id, channel_id) do
    ch_id = channel.id
    Subscription
    |> where([s], s.channel_id == ^ch_id and s.client_id == ^client_id)
    |> Repo.one
    |> case do
      nil ->
        Helpers.response_message(channel_id, text: "Your not subscribed to the ", code: channel.name, text: " channel.")
      subs ->
        Repo.delete! subs
        Helpers.response_message(channel_id, text: "You have left to the ", code: channel.name, text: " channel.")
    end
  end

  def channel_command(:open, %Channel{} = channel, client_id, channel_id) do
    # send open channel to the user
    %{}
  end

  def channel_command(:archive, %Channel{archived: true} = channel, client_id, channel_id) do
    Helpers.response_message(channel_id, text: "Channel with name ", code: channel.name, text: " is already archived.")
  end

  def channel_command(:archive, %Channel{} = channel, client_id, channel_id) do
    channel
    |> Channel.changeset(%{archived: true})
    |> Repo.update
    |> case do
      {:ok, _} ->
        Helpers.response_message(channel_id, text: "Channel with name ", code: channel.name, text: " has been archived successfully.")
      {:error, cs} ->
        Logger.warn "error archiving channel #{inspect cs.errors}"
        Helpers.response_message(channel_id, text: "Channel with name ", code: channel.name, text: " was not archived.")
    end
  end

  def channel_command(:unarchive, %Channel{archived: false} = channel, client_id, channel_id) do
    Helpers.response_message(channel_id, text: "Channel with name ", code: channel.name, text: " is not archived.")
  end

  def channel_command(:unarchive, %Channel{} = channel, client_id, channel_id) do
    channel
    |> Channel.changeset(%{archived: false})
    |> Repo.update
    |> case do
      {:ok, _} ->
        Helpers.response_message(channel_id, text: "Channel with name ", code: channel.name, text: " has been unarchived successfully.")
      {:error, cs} ->
        Logger.warn "error unarchiving channel #{inspect cs.errors}"
        Helpers.response_message(channel_id, text: "Channel with name ", code: channel.name, text: " was not unarchived.")
    end
  end

  def channel_command(:invite_all_to, %Channel{} = channel, client_id, channel_id) do
    to_channel = Helpers.get(Channel, channel.id).id
    from_channel = channel_id

    Subscription.get_all_for_channel(from_channel)
    |> preload([:client])
    |> Repo.all
    |> Enum.each(fn subs ->
      # TODO: check for errors here
      invite_client(subs.client.id, to_channel)
    end)

    Helpers.response_message(channel_id, text: "The users have been added.")
  end

  def channel_command(:invite_all_from, %Channel{} = channel, client_id, channel_id) do
    from_channel = Helpers.get(Channel, channel.id).id
    to_channel = channel_id

    Subscription.get_all_for_channel(from_channel)
    |> preload([:client])
    |> Repo.all
    |> Enum.each(fn subs ->
      # TODO: check for errors here
      invite_client(subs.client.id, to_channel)
    end)

    Helpers.response_message(channel_id, text: "The users have been added.")
  end

  ##################
  # client commands

  @client_commands ~w(invite kick mute unmute)a

  def client_command(command, name, client_id, channel_id) when command in @client_commands and is_binary(name) do
    case Helpers.get_by(Client, :nickname, name) do
      nil ->
        Helpers.response_message(channel_id, text: "The user ", code: "@" <> name, text: " does not exists")
      client ->
        client_command(command, client, client_id, channel_id)
    end
  end

  def client_command(:invite, %Client{} = client, client_id, channel_id) do
    client.id
    |> invite_client(channel_id)
    |> case do
      {:ok, subs} ->
        notify_client_action(client, client_id, channel_id, "added")
      {:error, _} ->
        Helpers.response_message(channel_id, text: "Problem inviting ", code: client.nickname, text: " to this channel.")
    end
  end

  def client_command(:kick, %Client{} = client, client_id, channel_id) do
    c_id = client.id
    Subscription
    |> where([s], s.channel_id == ^channel_id and s.client_id == ^c_id)
    |> Repo.one
    |> case do
      nil ->
        Helpers.response_message(channel_id, text: "User ", code: client.nickname, text: " is not subscribed to this channel.")
      subs ->
        Repo.delete! subs
        notify_client_action(client, client_id, channel_id, "removed")
    end
  end

  def client_command(:mute, %Client{} = client, client_id, channel_id) do
    case mute_client(client, client_id, channel_id) do
      {:error, response_message} -> response_message
      {:ok, _} -> notify_client_action(client, client_id, channel_id, "muted")
    end
  end

  def client_command(:unmute, %Client{} = client, client_id, channel_id) do
    case mute_client(client, client_id, channel_id) do
      {:error, response_message} -> response_message
      {:ok, _} -> notify_client_action(client, client_id, channel_id, "unmuted")
    end
  end

  # TODO: This needs to be broadcast to the channel
  defp notify_client_action(client, client_id, channel_id, action) do
    owner = Helpers.get(Client, client_id)
    t1 = content_tag :em do
     client.nickname
    end
    t2 = content_tag :em do
     owner.nickname
    end
    Helpers.response_message(channel_id, text: "User ", tag: t1, text: " #{action} by ", tag: t2, text: ".")
  end

  def mute_client(%{id: id} = client, client_id, channel_id) do
    %Mute{}
    |> Mute.changeset(%{client_id: id, channel_id: channel_id})
    |> Repo.insert
    |> case do
      {:error, cs} ->
        Logger.warn "mute cs errors, #{inspect cs.errors}"
        {:error, Helpers.response_message(channel_id, text: "User ", code: "@" <> client.nickname, text: " already muted.")}
      mute ->
        {:ok, mute}
    end
  end

  def unmute_client(%{id: id} = client, client_id, channel_id) do
    Mute
    |> where([m], m.client_id == ^id and m.channel_id == ^channel_id)
    |> Repo.one
    |> case do
      nil ->
        {:error, Helpers.response_message(channel_id, text: "User ", code: "@" <> client.nickname, text: " is not muted.")}
      mute ->
        Repo.delete mute
        {:ok, "unmuted"}
    end
  end

  def invite_client(client_id, channel_id) do
    %Subscription{}
    |> Subscription.changeset(%{client_id: client_id, channel_id: channel_id})
    |> Repo.insert
  end

  #################
  # Helpers

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
