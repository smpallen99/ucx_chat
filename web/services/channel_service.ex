defmodule UcxChat.ChannelService do
  @moduledoc """
  Helper functions used by the controller, channel, and model for Channels
  """
  use UcxChat.Web, :service

  # import Phoenix.HTML.Tag, only: [content_tag: 2]
  import Ecto.Query
  import UcxChat.NotifierService

  alias UcxChat.{
    Settings, User, Repo, Channel, Subscription, MessageService, User,
    ChatDat, Direct, Mute, UserChannel, UserRole, Permission, SideNavService
  }
  alias UcxChat.ServiceHelpers, as: Helpers
  require UcxChat.ChatConstants, as: CC
  alias Ecto.Multi

  require Logger
  require IEx

  # @public_channel  0
  # @private_channel 1
  # @direct_message  2
  # @stared_room     3

  def create_subscription(%Channel{} = channel, user_id) do
    %Subscription{}
    |> Subscription.changeset(%{user_id: user_id, channel_id: channel.id})
    |> Repo.insert
  end

  @doc """
  Create a channel subscription

  Creates the subscription but does not account the join
  """
  def create_subscription(channel_id, user_id) do
    Channel
    |> Helpers.get!(channel_id)
    |> create_subscription(user_id)
  end

  def invite_user(%User{} = current_user, channel_id, user_id) do
    current_user.id
    |> invite_user(channel_id)
    |> case do
      {:ok, subs} ->
        notify_user_action(current_user, user_id, channel_id, "added")
        {:ok, subs}
      error ->
        error
    end
  end

  @doc """
  Create a channel subscription and announce the join if configured.
  """
  def join_channel(%Channel{} = channel, user_id) do
    channel
    |> create_subscription(user_id)
    |> case do
      {:ok, subs} ->
        UserChannel.join_room(user_id, channel.name)
        unless Settings.hide_user_join() do
          # here
          # broadcast_message(~g"Has joined the channel.", channel.name, user_id, channel.id, system: true, sequential: false)
          # notify_action(socket, :join, channel.name, user_id, channel.id)
        end
        {:ok, subs}
      error ->
        error
    end
  end
  def join_channel(channel_id, user_id) do
    Channel
    |> Helpers.get!(channel_id)
    |> join_channel(user_id)
  end

  # def room_type(:public), do: @public_channel
  # def room_type(:private), do: @private_channel
  # def room_type(:direct), do: @direct_message
  # def room_type(:stared), do: @stared_room

  def set_subscription_state(channel, user_id, state) when state in [true, false] do
    channel
    |> Subscription.get(user_id)
    |> Repo.one
    |> case do
      nil -> nil
      sub ->
        sub
        |> Subscription.changeset(%{open: state})
        |> Repo.update
    end
  end
  def set_subscription_state_room(name, user_id, state) when state in [true, false] do
    name
    |> Subscription.get_by_room(user_id)
    |> Repo.one
    |> case do
      nil -> nil
      sub ->
        sub
        |> Subscription.changeset(%{open: state})
        |> Repo.update
    end
  end

  def get_unread(channel_id, user_id) do
    channel_id
    |> Subscription.get(user_id)
    |> Repo.one
    |> case do
      nil -> 0
      sub -> sub.unread
    end
  end

  def clear_unread(channel_id, user_id) do
    channel_id
    |> Subscription.get(user_id)
    |> Repo.one
    |> case do
      nil -> nil
      sub ->
        sub
        |> Subscription.changeset(%{unread: 0})
        |> Repo.update
    end
  end

  def increment_unread(channel_id, user_id) do
    with query <- Subscription.get(channel_id, user_id),
         sub when not is_nil(sub) <- Repo.one(query),
         unread <- sub.unread + 1,
         changeset <- Subscription.changeset(sub, %{unread: unread}),
         {:ok, _} <- Repo.update(changeset) do
      unread
    else
      _ -> 0
    end
  end

  def get_has_unread(channel_id, user_id) do
    case Subscription.get(channel_id, user_id) |> Repo.one do
      nil ->
        raise "Subscription for channel: #{channel_id}, user: #{user_id} not found"
      %{has_unread: unread} ->
        unread
    end
  end

  def set_has_unread(channel_id, user_id, value \\ true) do
    case Subscription.get(channel_id, user_id) |> Repo.one do
      nil ->
        {:error, :not_found}
      subs ->
        subs
        |> Subscription.changeset(%{has_unread: value})
        |> Repo.update
    end
  end

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

  def side_nav_where(%User{account: %{chat_mode: true}}, user_id) do
    Subscription
    |> where([cc], cc.user_id == ^user_id and cc.type in [2, 3])
  end

  def side_nav_where(_user, user_id) do
    Subscription
    |> where([cc], cc.user_id == ^user_id)
  end

  ##################
  # Repo Multi

  def insert_channel!(%{user_id: user_id} = params) do
    User
    |> Helpers.get!(user_id, preload: [:roles])
    |> insert_channel!(params)
  end
  def insert_channel!(user, params) do
    case insert_channel user, params do
      {:ok, channel} -> channel
      _ -> raise "insert channel failed"
    end
  end

  def insert_channel(%{user_id: user_id} = params) do
    user = Helpers.get!(User, user_id, preload: [:roles])
    insert_channel(user, params)
  end
  def insert_channel(user, params) do
    multi =
      Multi.new
      |> Multi.insert(:channel, Channel.do_changeset(%Channel{}, user, params))
      |> Multi.run(:roles, &do_roles/1)
    Repo.transaction(multi)
    |> case do
      %{channel: channel} -> {:ok, channel}
      {:ok, %{channel: channel}} -> {:ok, channel}
    end
  end

  def delete_channel(socket, room, _user_id) do
    with channel when not is_nil(channel) <- Helpers.get_by(Channel, :name, room),
         changeset <- Channel.changeset_delete(channel),
         {:ok, _} <- Repo.delete(changeset) do
      Logger.debug "deleting room #{room}"
      Phoenix.Channel.broadcast socket, "room:delete", %{room: room, channel_id: channel.id}
      Phoenix.Channel.broadcast socket, "reload", %{location: "/"}
      {:ok, %{success: ~g"The room has been deleted", reload: true}}
    else
      _ ->
        {:error, %{error: ~g"Problem deleting the channel"}}
    end
  end

  def do_roles(%{channel: %{id: ch_id, user_id: u_id} = channel}) do
    case Repo.insert(UserRole.changeset(%UserRole{}, %{user_id: u_id, role: "owner", scope: ch_id})) do
      {:ok, _} -> {:ok, channel}
      error -> error
    end
  end

  def add_moderator(_channel, _user_id) do

  end
  ##################
  #

  def get_side_nav_rooms(%User{} = user) do
    user
    |> Channel.get_all_channels
    |> order_by([c], [asc: c.name])
    |> Repo.all
  end

  def build_active_room(%Channel{} = channel) do
    %{
      active: true,
      alert: false,
      archived: channel.archived,
      can_leave: false,
      channel_id: channel.id,
      channel_type: channel.type,
      display_name: channel.name,
      hidden: false,
      name: channel.name,
      room_icon: get_icon(channel.type),
      type: room_type(channel.type),
      unread: false,
      user_status: "offline"
    }
  end

  def unhide_current_channel(%{channel_id: channel_id} = cc, channel_id) do
    Logger.debug "unhiding channel name: #{inspect cc.channel.name}"
    unhide_subscription(cc)
  end
  def unhide_current_channel(cc, _channel_id), do: cc

  @doc """
  Get the side_nav data used in the side_nav templates
  """
  # def get_side_nav(%User{id: id}, channel_id), do: get_side_nav(id, channel_id)
  def get_side_nav(%User{id: id} = user, channel_id) do
    channel = if channel_id do
      Helpers.get(Channel, channel_id) || %Channel{}
    else
      %Channel{}
    end
    chat_mode = user.account.chat_mode
    rooms =
      user
      |> side_nav_where(id)
      |> preload([:channel])
      |> Repo.all
      |> Enum.map(fn cc ->
        chan = cc.channel
        open = chan.id == channel_id
        type = get_chan_type(cc.type, chan.type)
        {display_name, user_status} = get_channel_display_name(type, chan, id)
        # if chan.type == 2 do
        #   Logger.warn "cc: #{inspect cc}"
        # end
        unread = if cc.unread == 0, do: false, else: cc.unread
        cc = unhide_current_channel(cc, channel_id)
        %{
          open: open, unread: unread, alert: cc.alert, user_status: user_status,
          can_leave: chan.type != 2, archived: false, name: chan.name, hidden: cc.hidden,
          room_icon: get_icon(chan.type), channel_id: chan.id, channel_type: chan.type,
          type: type, display_name: display_name, active: chan.active
        }
      end)
      |> Enum.filter(&(&1.active))
      |> Enum.sort(fn a, b ->
        String.downcase(a.display_name) < String.downcase(b.display_name)
      end)
    rooms = Enum.reject rooms, fn %{channel_type: chan_type, hidden: hidden} ->
      chat_mode && (chan_type in [0,1]) or hidden
    end
    active_room = Enum.find(rooms, &(&1[:active])) || build_active_room(channel)

    room_map = Enum.reduce rooms, %{}, fn room, acc ->
      put_in acc, [room[:channel_id]], room
    end

    types = Enum.group_by(rooms, fn item ->
      case Map.get(item, :type) do
        :private -> :public
        other -> other
      end
    end)
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
      |> Enum.reject(fn %{type: type} -> type == :public && chat_mode end)
      |> Enum.map(fn %{type: type} = bt ->
        case room_types[type] do
          nil -> bt
          other -> other
        end
      end)

    %{room_types: room_types, room_map: room_map, rooms: [], active_room: active_room}
  end

  def get_channel_display_name(type, %Channel{id: id, name: name}, user_id) when type == :direct or type == :stared do
    Direct
    |> where([d], d.channel_id == ^id and d.user_id == ^user_id)
    |> Repo.one
    |> case do
      %{} = direct ->
        username = Map.get(direct, :users)
        user = Repo.one! User.user_from_username(username)
        {username, UcxChat.PresenceAgent.get(user.id)}
      _ ->  {name, "offline"}
    end
  end
  def get_channel_display_name(_, %Channel{name: name}, _), do: {name, "offline"}

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

  def room_redirect(room, display_name) do
    channel =
      Channel
      |> where([c], c.name == ^room)
      |> Repo.one!
    "/" <> Channel.room_route(channel) <> "/" <> display_name
  end

  defp unhide_subscription(subscription) do
    subscription
    |> Subscription.changeset(%{hidden: false})
    |> Repo.update!
  end

  def open_room(user_id, room, old_room, display_name) do
    Logger.warn "open_room room: #{inspect room}, old_room: #{inspect old_room}"
    # Logger.warn "ChannelService.open_room room: #{inspect room}, display_name: #{inspect display_name}"
    user = Helpers.get_user!(user_id)

    channel = Helpers.get_by! Channel, :name, room, preload: [:subscriptions]
    # old_channel = Helpers.get_by! Channel, :name, old_room, preload: [:subscriptions]

    # {subscribed, hidden} = Channel.subscription_status(channel, user.id)

    channel.id
    |> set_subscription_state(user_id, true)

    old_room
    |> set_subscription_state_room(user_id, false)

    user
    |> User.changeset(%{open_id: channel.id})
    |> Repo.update!

    messages = MessageService.get_messages(channel.id, user)

    chatd =
      user
      |> ChatDat.new(channel, messages)
      |> ChatDat.get_messages_info

    # box_html =
    #   "messages_box.html"
    #   |> UcxChat.MasterView.render(chatd: chatd)
    #   |> Phoenix.HTML.safe_to_string

    # header_html =
    #   "messages_header.html"
    #   |> UcxChat.MasterView.render(chatd: chatd)
    #   |> Phoenix.HTML.safe_to_string
    html =
      "room.html"
      |> UcxChat.MasterView.render(chatd: chatd)
      |> Phoenix.HTML.safe_to_string

    side_nav_html = SideNavService.render_rooms_list(channel.id, user_id )

    %{
      display_name: display_name,
      room_title: room,
      channel_id: channel.id,
      html: html,
      # box_html: box_html,
      # header_html: header_html,
      side_nav_html: side_nav_html,
      room_route: Channel.room_route(channel)
    }
  end

  def toggle_favorite(user_id, channel_id) do
    cc = Helpers.get_channel_user(channel_id, user_id, preload: [:channel])
    cc_type = if cc.type == room_type(:stared) do
      # change it back
      cc.channel.type
    else
      # star it
      room_type(:stared)
    end
    user = Repo.one!(from u in User, where: u.id == ^user_id, preload: [:account])
    Subscription.changeset(cc, %{type: cc_type}) |> Repo.update!
    chatd = ChatDat.new user, cc.channel, []
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

  def add_direct(username, user_id, channel_id) do
    user_orig = Helpers.get(User, user_id)
    user_dest = Helpers.get_by(User, :username, username)

    name = user_orig.username <> "__" <> username
    Logger.warn "name: #{inspect name}"
    channel = case Helpers.get_by(Channel, :name, name) do
      %Channel{} = channel ->
        channel
      _ ->
        do_add_direct(name, user_orig, user_dest, channel_id)
    end

    # user = Repo.one!(from u in User, where: u.id == ^user_id, preload: [:account, :roles])
    user =
      user_id
      |> Helpers.get_user!
      |> User.changeset(%{open_id: channel.id})
      |> Repo.update!

    chatd = ChatDat.new user, channel, []

    messages_html =
      "messages_header.html"
      |> UcxChat.MasterView.render(chatd: chatd)
      |> Phoenix.HTML.safe_to_string

    side_nav_html =
      "rooms_list.html"
      |> UcxChat.SideNavView.render(chatd: chatd)
      |> Phoenix.HTML.safe_to_string

    resp = %{
      messages_html: messages_html,
      side_nav_html: side_nav_html,
      display_name: username,
      channel_id: channel.id,
      room: channel.name,
      room_route: chatd.room_route
    }
    {:ok, resp}
  end

  defp do_add_direct(name, user_orig, user_dest, _channel_id) do
    # create the channel
    {:ok, channel} = insert_channel(%{user_id: user_orig.id, name: name, type: room_type(:direct)})

    # Create the cc's, and the directs one for each user
    user_names = %{user_orig.id => user_dest.username, user_dest.id => user_orig.username}

    for user <- [user_orig, user_dest] do
      %Subscription{}
      |> Subscription.changeset(%{channel_id: channel.id, user_id: user.id, type: room_type(:direct)})
      |> Repo.insert!
      %Direct{}
      |> Direct.changeset(%{users: user_names[user.id], user_id: user.id, channel_id: channel.id})
      |> Repo.insert!
    end
    UcxChat.Endpoint.broadcast! CC.chan_user() <> to_string(user_dest.id), "direct:new", %{room: channel.name}
    channel
  end

  ###################
  # channel commands

  def channel_command(socket, :unhide, name, user_id, _channel_id) do
    channel_id =
      Channel
      |> where([c], c.name == ^name)
      |> select([c], c.id)
      |> Repo.one

    Subscription
    |> where([s], s.channel_id == ^channel_id and s.user_id == ^user_id)
    |> Repo.one
    |> case do
      nil ->
        {:error, "You are not subscribed to that room"}
      subs ->
        subs
        |> Subscription.changeset(%{hidden: false})
        |> Repo.update
        |> case do
          {:ok, _} ->
            Phoenix.Channel.broadcast socket, "user:action", %{action: "unhide", user_id: user_id, channel_id: channel_id}
            {:ok, ""}
          {:error, _} ->
            {:error, ~g"Could not unhide that room"}
        end
    end
  end

  def channel_command(socket, :hide, name, user_id, _channel_id) do
    channel_id =
      Channel
      |> where([c], c.name == ^name)
      |> select([c], c.id)
      |> Repo.one

    Subscription
    |> where([s], s.channel_id == ^channel_id and s.user_id == ^user_id)
    |> Repo.one
    |> case do
      nil ->
        {:error, ~g"You are not subscribed to that room"}
      subs ->
        subs
        |> Subscription.changeset(%{hidden: true})
        |> Repo.update
        |> case do
          {:ok, _} ->
            Phoenix.Channel.broadcast socket, "user:action", %{action: "hide", user_id: user_id}
            {:ok, ""}
          {:error, _} ->
            {:error, ~g"Could not hide that room"}
        end
    end
  end

  def channel_command(socket, :create, name, user_id, channel_id) do
    Logger.warn "name: #{inspect name}"
    if is_map(name) do
      Helpers.response_message(channel_id, ~g"The channel " <> "`##{name}`" <> ~g" already exists.")
    else
      insert_channel(%{name: name, user_id: user_id})
      |>case do
        {:ok, channel} ->
          channel_command(socket, :join, channel, user_id, channel_id)

          {:ok, ~g"Channel created successfully"}

        {:error, _} ->
          {:error, ~g"There was a problem creating " <> "`##{name}`" <> ~g" channel."}
      end
    end
  end

  def channel_command(socket, :leave, name, user_id, _) when is_binary(name) do
    Logger.warn "name: #{inspect name}"
    case Helpers.get_by(Channel, :name, name) do
      nil ->
        {:error, ~g"The channels does not exist"}
      channel ->
        channel_command(socket, :leave, channel, user_id, channel.id)
    end
  end
  @channel_commands ~w(join leave open archive unarchive invite_all_to invite_all_from)a

  def channel_command(socket, command, name, user_id, channel_id) when command in @channel_commands and is_binary(name) do
    case Helpers.get_by(Channel, :name, name) do
      nil ->
        {:error, ~g"The channel " <> "`##{name}`" <> ~g" does not exists"}
      channel ->
        channel_command(socket, command, channel, user_id, channel_id)
    end
  end

  def channel_command(_socket, :join, %Channel{} = channel, user_id, _channel_id) do
    channel
    |> add_user_to_channel(user_id)
    |> case do
      {:ok, _subs} ->
        {:ok, ~g"You have joined the " <> "`#{channel.name}`" <> ~g" channel."}
      {:error, _} ->
        {:error, ~g"Problem joining " <> "`#{channel.name}`" <> ~g" channel."}
    end
  end

  def channel_command(_socket, :leave, %Channel{} = channel, user_id, _channel_id) do
    # Logger.error ".... channel.name: #{inspect channel.name}, user_id: #{inspect user_id}, channel.id: #{inspect channel.id}"
    channel
    |> remove_user_from_channel(user_id)
    |> case do
      nil ->
        {:error, ~g"Your not subscribed to the " <> "`#{channel.name}`" <> ~g" channel."}
      _subs ->
        {:ok, ~g"You have left to the " <> "`#{channel.name}`" <> ~g" channel."}
    end
  end

  def channel_command(socket, :open, %Channel{name: name} = _channel, _user_id, _channel_id) do
    # send open channel to the user
    # old_room = Helpers.get!(Channel, socket.assigns.channel_id) |> Map.get(:name)
    # Logger.warn "old_room: #{inspect old_room}, channel: #{inspect channel}"
    # open_room(socket.assigns[:user_id], old_room, name, name)
    # Helpers.response_message(channel_id, "That command is not yet supported")
    Phoenix.Channel.push socket, "room:open", %{room: name}
    {:ok, %{}}
  end

  def channel_command(_socket, :archive, %Channel{archived: true} = channel, _user_id, channel_id) do
    Helpers.response_message(channel_id, "Channel with name `#{channel.name}` is already archived.")
  end

  def channel_command(socket, :archive, %Channel{id: id} = channel, user_id, channel_id) do
    user = Helpers.get_user! user_id
    channel
    |> Channel.do_changeset(user, %{archived: true})
    |> Repo.update
    |> case do
      {:ok, _} ->
        Logger.warn "archiving... #{id}, channel_id: #{inspect channel_id}, channel_name: #{channel.name}"
        Subscription
        |> where([s], s.channel_id == ^id)
        |> Repo.update_all(set: [hidden: true])
        notify_action(socket, :archive, channel, user)
        # notify_user_action2(socket, user, user_id, id, &format_binary_msg(&1, &2, "archived"))
        # Phoenix.Channel.broadcast! socket, "room:state_change", %{change: "archive"}
        {:ok, ~g"Channel with name " <> "`#{channel.name}`" <> ~g" has been archived successfully."}
      {:error, cs} ->
        Logger.warn "error archiving channel #{inspect cs.errors}"
        {:error, ~g"Channel with name " <> "`#{channel.name}`" <> ~g" was not archived."}
    end
  end

  def channel_command(_socket, :unarchive, %Channel{archived: false} = channel, _user_id, _channel_id) do
    {:error, ~g"Channel with name " <> "`#{channel.name}`" <> ~g" is not archived."}
  end

  def channel_command(socket, :unarchive, %Channel{id: id} = channel, user_id, _channel_id) do
    user = Helpers.get_user! user_id
    channel
    |> Channel.do_changeset(user, %{archived: false})
    |> Repo.update
    |> case do
      {:ok, _} ->
        Logger.warn "unarchiving... #{id}"
        Subscription
        |> where([s], s.channel_id == ^id)
        |> Repo.update_all(set: [hidden: false])
        # Phoenix.Channel.broadcast socket, "room:state_change", %{change: "unarchive"}
        # notify_action(socket, :unarchive, channel.name, user, channel.id)
        notify_action(socket, :unarchive, channel, user)
        # notify_user_action2(socket, user, user_id, id, &format_binary_msg(&1, &2, "unarchived"))
        {:ok, ~g"Channel with name " <> "`#{channel.name}`" <> ~g" has been unarchived successfully."}
      {:error, cs} ->
        Logger.warn "error unarchiving channel #{inspect cs.errors}"
        {:erorr, ~g"Channel with name " <> "`#{channel.name}`" <> ~g" was not unarchived."}
    end
  end

  def channel_command(_socket, :invite_all_to, %Channel{} = channel, _user_id, channel_id) do
    to_channel = Helpers.get(Channel, channel.id).id
    from_channel = channel_id

    Subscription.get_all_for_channel(from_channel)
    |> preload([:user])
    |> Repo.all
    |> Enum.each(fn subs ->
      # TODO: check for errors here
      invite_user(subs.user.id, to_channel)
    end)

    {:ok, "The users have been added."}
  end

  def channel_command(_socket, :invite_all_from, %Channel{} = channel, _user_id, channel_id) do
    from_channel = Helpers.get(Channel, channel.id).id
    to_channel = channel_id

    Subscription.get_all_for_channel(from_channel)
    |> preload([:user])
    |> Repo.all
    |> Enum.each(fn subs ->
      # TODO: check for errors here
      invite_user(subs.user.id, to_channel)
    end)

    {:ok, ~g"The users have been added."}
  end

  ##################
  # user commands

  @user_commands ~w(invite kick mute unmute block_user unblock_user)a

  def user_command(socket, command, name, user_id, channel_id) when command in @user_commands and is_binary(name) do
    case Helpers.get_by(User, :username, name) do
      nil ->
        {:error, ~g"The user " <> "`@#{name}`" <> ~g" does not exists"}
      user ->
        user_command(socket, command, user, user_id, channel_id)
    end
  end
  def user_command(_socket, :invite, %User{} = user, user_id, channel_id) do
    user
    |> invite_user(channel_id, user_id)
    |> case do
      {:ok, _subs} ->
        {:ok, ~g"User added"}
      {:error, _} ->
        {:error, ~g"Problem inviting " <> "`#{user.username}`" <> ~g" to this channel."}
    end
  end

  def user_command(socket, :kick, %User{} = user, user_id, channel_id) do
    Channel
    |> Helpers.get!(channel_id)
    |> remove_user_from_channel(user.id)
    |> case do
      nil ->
        {:error, ~g"User " <> "`#{user.username}`" <> ~g" is not subscribed to this channel."}
      _subs ->
        notify_user_action2(socket, user, user_id, channel_id, &format_binary_msg(&1, &2, "removed"))
        {:ok, ~g"User removed"}
    end
  end

    # field :hide_user_join, :boolean, default: false
    # field :hide_user_leave, :boolean, default: false
    # field :hide_user_removed, :boolean, default: false
    # field :hide_user_added, :boolean, default: false
  def user_command(socket, :block_user, %User{} = user, user_id, channel_id) do
    case block_user(user, user_id, channel_id) do
      {:ok, msg} ->
        # unless Settings.hide_user_muted() do
        #   notify_user_action2 socket, user, user_id, channel_id, &format_binary_msg(&1, &2, "muted")
        # end
        Phoenix.Channel.broadcast socket, "room:state_change", %{change: "block"}
        Phoenix.Channel.broadcast socket, "user:action", %{action: "block", user_id: user.id}
        # Logger.warn "mute #{user.id} by #{user_id}...."
        {:ok, msg}
      error ->
        # Logger.error "user_command error #{inspect error}"
        error
    end
  end

  def user_command(socket, :unblock_user, %User{} = user, user_id, channel_id) do
    case unblock_user(user, user_id, channel_id) do
      {:ok, msg} ->
        # unless Settings.hide_user_muted() do
        #   notify_user_action2 socket, user, user_id, channel_id, &format_binary_msg(&1, &2, "muted")
        # end
        Phoenix.Channel.broadcast! socket, "room:state_change", %{change: "unblock"}
        Phoenix.Channel.broadcast socket, "user:action", %{action: "block", user_id: user.id}
        # Logger.warn "mute #{user.id} by #{user_id}...."
        {:ok, msg}
      error ->
        # Logger.error "user_command error #{inspect error}"
        error
    end
  end

  def user_command(socket, :mute, %User{} = user, user_id, channel_id) do
    case mute_user(user, user_id, channel_id) do
      {:ok, msg} ->
        unless Settings.hide_user_muted() do
          notify_user_action2 socket, user, user_id, channel_id, &format_binary_msg(&1, &2, "muted")
        end
        Phoenix.Channel.broadcast socket, "user:action", %{action: "mute", user_id: user.id}
        # Logger.warn "mute #{user.id} by #{user_id}...."
        {:ok, msg}
      error ->
        # Logger.error "user_command error #{inspect error}"
        error
    end
  end

  def user_command(socket, :unmute, %User{} = user, user_id, channel_id) do
    case unmute_user(user, user_id, channel_id) do
      {:ok, msg} ->
        unless Settings.hide_user_muted() do
          notify_user_action2 socket, user, user_id, channel_id, &format_binary_msg(&1, &2, "unmuted")
        end
        Phoenix.Channel.broadcast socket, "user:action", %{action: "mute", user_id: user.id}
        # Logger.warn "unmute #{user.id} by #{user_id}...."
        {:ok, msg}
      error ->
        # Logger.error "user_command error #{inspect error}"
        error
    end
  end

  def user_command(socket, action, %User{} = user, user_id, channel_id) when action in [:set_owner, :unset_owner] do
    string = if action == :set_owner, do: "was set owner", else: "is no longer owner"
    case apply(__MODULE__, action, [user, user_id, channel_id]) do
      {:ok, msg} ->
        notify_user_action2 socket, user, user_id, channel_id, &format_binary_msg(&1, &2, string)
        Phoenix.Channel.broadcast socket, "user:action", %{action: "owner", user_id: user.id}
        Logger.debug "#{inspect action} #{user.id} by #{user_id}...."
        {:ok, msg}
      error ->
        Logger.error "user_command error #{inspect error}"
        error
    end
  end

  def user_command(socket, action, %User{} = user, user_id, channel_id) when action in [:set_moderator, :unset_moderator] do
    string = if action == :set_moderator, do: ~g"was set moderator", else: ~g"is no longer moderator"
    case apply(__MODULE__, action, [user, user_id, channel_id]) do
      {:ok, msg} ->
        notify_user_action2 socket, user, user_id, channel_id, &format_binary_msg(&1, &2, string)
        Phoenix.Channel.broadcast socket, "user:action", %{action: "moderator", user_id: user.id}
        Logger.debug "#{inspect action} #{user.id} by #{user_id}...."
        {:ok, msg}
      error ->
        Logger.error "user_command error #{inspect error}"
        error
    end
  end

  def user_command(socket, :remove_user, %User{} = user, user_id, channel_id) do
    case apply(__MODULE__, :remove_user, [user, user_id, channel_id]) do
      {:ok, msg} ->
        notify_user_action2 socket, user, user_id, channel_id, &format_binary_msg(&1, &2, "removed by")
        Phoenix.Channel.broadcast socket, "user:action", %{action: "removed", user_id: user.id}
        Logger.debug "#{inspect :remove_user} #{user.id} by #{user_id}...."
        {:ok, msg}
      error ->
        Logger.error "user_command error #{inspect error}"
        error
    end
  end

  def user_command(_socket, action, %User{}, _user_id, _channel_id) do
    raise "user command unknown action #{inspect action}"
  end

  def format_binary_msg(n1, n2, operation) do
    ~g"User" <> " <em class='username'>#{n1}</em> " <> Gettext.gettext(UcxChat.Gettext, operation) <> " " <> ~g"by" <> " <em class='username'>#{n2}</em>."
  end
  # def notify_action(socket, action, resource, owner_id, channel_id)

  def notify_user_action2(socket, user, user_id, channel_id, fun) do
    owner = Helpers.get(User, user_id)
    body = fun.(user.username, owner.username)
    broadcast_message2(socket, body, user_id, channel_id, system: true)
  end
  defp notify_user_action(_user, _user_id, _channel_id, _action) do
    # owner = Helpers.get(User, user_id)
    # t1 = content_tag :em do
    #  user.username
    # end
    # t2 = content_tag :em do
    #  owner.username
    # end
    # broadcast_message(body, room, user_id, channel_id)
    #Helpers.response_message(channel_id, text: "User ", tag: t1, text: " #{action} by ", tag: t2, text: ".")
  end

  def block_user(%{id: _id}, _user_id, channel_id) do
    # user = Helpers.get_user! user_id
    Channel
    |> Helpers.get!(channel_id)
    |> Channel.blocked_changeset(true)
    |> Repo.update
    |> case do
      {:error, _cs} ->
        # {:error, Helpers.response_message(channel_id, text: "User ", code: "@" <> user.username, text: " already muted.")}
        {:error, ~g"Could not block user"}
      _ ->
        {:ok, ~g"blocked"}
    end
  end

  def unblock_user(_user, _user_id, channel_id) do
    # user = Helpers.get_user! user_id
    Channel
    |> Helpers.get!(channel_id)
    |> Channel.blocked_changeset(false)
    |> Repo.update
    |> case do
      {:error, _cs} ->
        # {:error, Helpers.response_message(channel_id, text: "User ", code: "@" <> user.username, text: " already muted.")}
        {:error, ~g"Could not unblock user"}
      _ ->
        {:ok, ~g"unblocked"}
    end
  end

  def mute_user(%{id: id} = user, user_id, channel_id) do
    if Permission.has_permission?(Helpers.get_user!(user_id), "mute-user", channel_id) do
      %Mute{}
      |> Mute.changeset(%{user_id: id, channel_id: channel_id})
      |> Repo.insert
      |> case do
        {:error, _cs} ->
          # {:error, Helpers.response_message(channel_id, text: "User ", code: "@" <> user.username, text: " already muted.")}
          {:error, ~g"User" <> " `@" <> user.username <> "` " <>  ~g"already muted."}
        _mute ->
          {:ok, ~g"muted"}
      end
    else
      {:error, :no_permission}
    end
  end

  def unmute_user(%{id: id} = user, user_id, channel_id) do
    if Permission.has_permission?(Helpers.get_user!(user_id), "mute-user", channel_id) do
      Mute
      |> where([m], m.user_id == ^id and m.channel_id == ^channel_id)
      |> Repo.one
      |> case do
        nil ->
          # {:error, Helpers.response_message(channel_id, text: "User ", code: "@" <> user.username, text: " is not muted.")}
          {:error, ~g"User" <> " `@" <> user.username <> "` " <> ~g"is not muted."}
        mute ->
          Repo.delete mute
          {:ok, ~g"unmuted"}
      end
    else
      {:error, :no_permission}
    end
  end

  def set_owner(%{id: id} = _user, _user_id, channel_id) do
    %UserRole{}
    |> UserRole.changeset(%{user_id: id, role: "owner", scope: channel_id})
    |> Repo.insert
    |> case do
      {:error, _cs} ->
        # {:error, Helpers.response_message(channel_id, text: "User ", code: "@" <> user.username, text: " already muted.")}
        {:error, ~g"Could not add role to user."}
      user_role ->
        {:ok, user_role}
    end
  end

  def unset_owner(%{id: id}, _user_id, channel_id) do
    owners = Repo.all(from r in UserRole, where: r.role == "owner" and  r.scope == ^channel_id)
    if length(owners) > 1 do
      owners
      |> Enum.find(&(&1.user_id == id))
      |> remove_role
    else
      {:error, ~g"This is the last owner. Please set a new owner before removing this one."}
    end
  end

  def set_moderator(%{id: id}, _user_id, channel_id) do
    %UserRole{}
    |> UserRole.changeset(%{user_id: id, role: "moderator", scope: channel_id})
    |> Repo.insert
    |> case do
      {:error, _cs} ->
        # {:error, Helpers.response_message(channel_id, text: "User ", code: "@" <> user.username, text: " already muted.")}
        {:error, ~g"Could not add user as moderator."}
      user_role ->
        {:ok, user_role}
    end
  end

  def unset_moderator(%{id: id}, _user_id, channel_id) do
    Repo.one(from r in UserRole, where: r.user_id == ^id and r.role == "moderator" and  r.scope == ^channel_id)
    |> remove_role
  end

  def remove_user(%{id: id}, _user_id, channel_id) do
    channel = Repo.get Channel, channel_id
    owners = Repo.all(from r in UserRole, where: r.user_id != ^id and r.role == "owner" and  r.scope == ^channel_id)
    if length(owners) > 0 do
      case remove_user_from_channel(channel, id) do
        nil ->
          {:error, ~g"User is not a member of this room."}
        _ ->
          {:ok, ""}
      end
    else
      {:error, ~g"You are the last owner. Please set a new owner before leaving this room."}
    end
  end

  def invite_user(user_id, channel_id) do
    Helpers.get!(Channel, channel_id)
    |> add_user_to_channel(user_id)
  end

  def remove_role(nil) do
    {:error, ~g"Role not found"}
  end
  def remove_role(user_role) do
    Repo.delete! user_role
    {:ok, :success}
  end

  #################
  # Helpers

  def get_templ(:stared), do: "stared_rooms.html"
  def get_templ(:direct), do: "direct_messages.html"
  def get_templ(_), do: "channels.html"

  def get_icon(%Channel{type: type}), do: get_icon(type)
  def get_icon(0), do: "icon-hash"
  def get_icon(1), do: "icon-lock"
  def get_icon(2), do: "icon-at"
  def get_icon(3), do: "icon-at"
  # def get_icon(:public), do: "icon-hash"
  # def get_icon(:private), do: "icon-hash"
  # def get_icon(:stared), do: "icon-hash"
  # def get_icon(:direct), do: "icon-at"

  # def broadcast_message(body, room, user_id, channel_id, opts \\ []) do
  #   {message, html} = MessageService.create_and_render(body, user_id, channel_id, opts)
  #   MessageService.broadcast_message(message.id, room, user_id, html)
  # end

  def broadcast_message2(socket, body, user_id, channel_id, opts \\ []) do
    {message, html} = MessageService.create_and_render(body, user_id, channel_id, opts)
    MessageService.broadcast_message(socket, message.id, user_id, html)
  end

  def remove_user_from_channel(channel, user_id) do
    ch_id = channel.id
    Subscription
    |> where([s], s.channel_id == ^ch_id and s.user_id == ^user_id)
    |> Repo.one
    |> case do
      nil -> nil
      subs ->
        Repo.delete! subs
        UserChannel.leave_room(user_id, channel.name)
        unless Settings.hide_user_leave() do
          # here
          # broadcast_message("Has left the channel.", channel.name, user_id, channel.id, system: true, sequential: false)
        end
        {:ok, ~g"removed"}
    end
  end

  def add_user_to_channel(channel, user_id) do
    channel
    |> join_channel(user_id)
    |> case do
      {:ok, _subs} ->
        {:ok, ~g"added"}
      result -> result
    end
  end

  def user_muted?(user_id, channel_id) do
    !! Repo.one(from m in Mute,
      where: m.user_id == ^user_id and m.channel_id == ^channel_id,
      select: true)
  end

  # def get_route(@stared_room, name), do: "/direct/" <> name
  # def get_route(@direct_message, name), do: "/direct/" <> name
  # def get_route(_, name), do: "/channel/" <> name
end
