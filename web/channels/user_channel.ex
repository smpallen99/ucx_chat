defmodule UcxChat.UserChannel do
  use Phoenix.Channel
  use UcxChat.ChannelApi
  use UcxChat.Web, :channel
  # alias UcxChat.Presence

  import Ecto.Query

  alias Phoenix.Socket.Broadcast
  alias UcxChat.{Subscription, Repo, Flex, FlexBarService, ChannelService, Channel, SideNavService}
  alias UcxChat.{AccountView, Account, AdminService, FlexBarView, UserSocket}
  alias UcxChat.{ChannelService, SubscriptionService}
  alias UcxChat.ServiceHelpers, as: Helpers
  require UcxChat.ChatConstants, as: CC

  require Logger

  def join_room(user_id, room) do
    # Logger.debug ("...join_room user_id: #{inspect user_id}")
    UcxChat.Endpoint.broadcast!(CC.chan_user() <> "#{user_id}", "room:join", %{room: room, user_id: user_id})
  end

  def leave_room(user_id, room) do
    UcxChat.Endpoint.broadcast!(CC.chan_user() <> "#{user_id}", "room:leave", %{room: room, user_id: user_id})
  end

  def notify_mention(%{user_id: user_id, channel_id: channel_id}) do
    UcxChat.Endpoint.broadcast!(CC.chan_user() <> "#{user_id}", "room:mention", %{channel_id: channel_id, user_id: user_id})
  end
  def user_state(user_id, state) do
    UcxChat.Endpoint.broadcast!(CC.chan_user() <> "#{user_id}", "user:state", %{state: state})
  end

  intercept ["room:join", "room:leave", "room:mention", "user:state", "direct:new"]

  def join(CC.chan_user() <>  user_id, params, socket) do
    debug(CC.chan_user() <> user_id, params)
    send(self(), :after_join)
    new_assigns = params |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end) |> Enum.into(%{})
    socket =
      socket
      |> struct(assigns: Map.merge(new_assigns, socket.assigns))
      |> assign(:subscribed, socket.assigns[:subscribed] || [])
      |> assign(:flex, Flex.new())
      |> assign(:user_state, "active")
    socket =
      Repo.all(from s in Subscription, where: s.user_id == ^user_id, preload: [:channel, {:user, :roles}])
      |> Enum.map(&(&1.channel.name))
      |> subscribe(socket)

    {:ok, socket}
  end

  ###############
  # Outgoing Incoming Messages

  def handle_out("room:join", msg, socket) do
    %{room: room} = msg
    UserSocket.push_message_box(socket, socket.assigns.channel_id, socket.assigns.user_id)
    update_rooms_list(socket)
    clear_unreads(room, socket)
    {:noreply, subscribe([room], socket)}
  end
  def handle_out("room:leave" = ev, msg, socket) do
    %{room: room} = msg
    debug ev, msg, "assigns: #{inspect socket.assigns}"
    # UserSocket.push_message_box(socket, socket.assigns.channel_id, socket.assigns.user_id)
    socket.endpoint.unsubscribe(CC.chan_room <> room)
    update_rooms_list(socket)
    {:noreply, assign(socket, :subscribed, List.delete(socket.assigns[:subscribed], room))}
  end
  def handle_out("room:mention", msg, socket) do
    push_room_mention(msg, socket)
    {:noreply, socket}
  end
  def handle_out("user:state", msg, socket) do
    {:noreply, handle_user_state(msg, socket)}
  end
  def handle_out("direct:new", msg, socket) do
    %{room: room} = msg
    update_rooms_list(socket)
    {:noreply, subscribe([room], socket)}
  end

  def handle_user_state(%{state: "idle"}, socket) do
    debug "idle", ""
    push socket, "focus:change", %{state: false, msg: "idle"}
    assign socket, :user_state, "idle"
  end
  def handle_user_state(%{state: "active"}, socket) do
    debug "active", ""
    push socket, "focus:change", %{state: true, msg: "active"}
    clear_unreads(socket)
    assign socket, :user_state, "active"
  end

  def push_room_mention(msg, socket) do
    %{channel_id: channel_id} = msg
    Process.send_after self(), {:update_mention, channel_id, socket.assigns.user_id}, 250
    socket
  end

  def push_update_direct_message(msg, socket) do
    %{channel_id: channel_id} = msg
    Process.send_after self(), {:update_direct_message, channel_id, socket.assigns.user_id}, 250
    socket
  end

  ###############
  # Incoming Messages

  def handle_in("subscribe" = ev, params, socket) do
    debug ev, params, "assigns: #{inspect socket.assigns}"
    {:noreply, socket}
  end

  def handle_in("flex:open:User Info" = ev, params, socket) do
    debug ev, params, "assigns: #{inspect socket.assigns}"
    args = %{"args" => %{"templ" => "users_list.html", "username" => "steve.pallen"}}
    {:noreply, open_flex_item(socket, "User Info", args)}
  end

  def handle_in("flex:open:" <> tab = ev, params, socket) do
    debug ev, params, "assigns: #{inspect socket.assigns}"
    {:noreply, toggle_flex(socket, tab, params)}
  end
  def handle_in("flex:item:open:" <> tab = ev, params, socket) do
    debug ev, params, "assigns: #{inspect socket.assigns}"
    {:noreply, open_flex_item(socket, tab, params)}
  end

  def handle_in("flex:close" = ev, params, socket) do
    debug ev, params
    {:noreply, socket}
  end

  def handle_in("flex:view_all:" <> tab = ev, params, %{assigns: assigns} = socket) do
    debug ev, params
    fl = assigns[:flex] |> Flex.view_all(assigns[:channel_id], tab)
    {:noreply, assign(socket, :flex, fl)}
  end

  def handle_in("side_nav:open" = ev, %{"page" => "account"} = params, socket) do
    debug ev, params

    user = Helpers.get_user!(socket)
    account_cs = Account.changeset(user.account, %{})
    html = Helpers.render(AccountView, "account_preferences.html", user: user, account_changeset: account_cs)
    push socket, "code:update", %{html: html, selector: ".main-content", action: "html"}

    html = Helpers.render(AccountView, "account_flex.html")
    {:reply, {:ok, %{html: html}}, socket}
  end
  def handle_in("side_nav:open" = ev, %{"page" => "admin"} = params, socket) do
    debug ev, params

    user = Helpers.get_user!(socket)

    html = UcxChat.AdminService.render_info(user)
    push socket, "code:update", %{html: html, selector: ".main-content", action: "html"}

    html = Helpers.render(UcxChat.AdminView, "admin_flex.html", user: user)
    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in("side_nav:more_channels" = ev, params, socket) do
    debug ev, params

    html = SideNavService.render_more_channels(socket.assigns.user_id)
    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in("side_nav:more_users" = ev, params, socket) do
    debug ev, params

    html = SideNavService.render_more_users(socket.assigns.user_id)
    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in("side_nav:close" = ev, params, socket) do
    debug ev, params

    {:noreply, socket}
  end

  def handle_in("account:preferences:save" = ev, params, socket) do
    debug ev, params, "assigns: #{inspect socket.assigns}"
    params =
      params
      |> Helpers.normalize_form_params
      |> Map.get("account")
    resp =
      socket
      |> Helpers.get_user!
      |> Map.get(:account)
      |> Account.changeset(params)
      |> Repo.update
      |> case do
        {:ok, _account} ->
          {:ok, %{success: ~g"Account updated successfully"}}
        {:error, _cs} ->
          {:ok, %{error: ~g"There a problem updating your account."}}
      end
    {:reply, resp, socket}
  end

  @links ~w(preferences profile)
  def handle_in(ev = "account_link:click:" <> link, params, socket) when link in @links do
    debug ev, params
    user = Helpers.get_user(socket.assigns.user_id)
    account_cs = Account.changeset(user.account, %{})
    html = Helpers.render(AccountView, "account_#{link}.html", user: user, account_changeset: account_cs)
    push socket, "code:update", %{html: html, selector: ".main-content", action: "html"}
    {:noreply, socket}
  end

  def handle_in(ev = "mode:set:" <> mode, params, socket) do
    debug ev, params
    mode = if mode == "im", do: true, else: false
    user = Helpers.get_user!(socket)

    resp =
      user
      |> Map.get(:account)
      |> Account.changeset(%{chat_mode: mode})
      |> Repo.update
      |> case do
        {:ok, _} ->
          push socket, "window:reload", %{}
          {:ok, %{}}
        {:error, _} ->
          {:error, %{error: ~g"There was a problem switching modes"}}
      end
    {:reply, resp, socket}
  end

  @links ~w(info general message permissions layout users rooms)
  def handle_in(ev = "admin_link:click:" <> link, params, socket) when link in @links do
    debug ev, params
    user = Helpers.get_user! socket
    html = AdminService.render user, link, "#{link}.html"
    push socket, "code:update", %{html: html, selector: ".main-content", action: "html"}
    {:noreply, socket}
  end

  def handle_in(ev = "admin:" <> link, params, socket) do
    debug ev, params
    AdminService.handle_in(link, params, socket)
  end

  def handle_in(ev = "flex:member-list:" <> action, params, socket) do
    debug ev, params
    FlexBarService.handle_in action, params, socket
  end

  def handle_in(ev = "update:currentMessage", %{"value" => value } = params, %{assigns: assigns} = socket) do
    debug ev, params
    SubscriptionService.update(assigns.channel_id, assigns.user_id, %{current_message: value})
    {:noreply, socket}
  end
  def handle_in(ev = "get:currentMessage", params, %{assigns: assigns} = socket) do
    debug ev, params
    channel = Helpers.get_by Channel, :name, params["room"]
    res = case SubscriptionService.get channel.id, assigns.user_id, :current_message do
      :error -> {:error, %{}}
      value -> {:ok, %{value: value}}
    end
    {:reply, res, socket}
  end
  def handle_in(ev = "last_read", params, %{assigns: assigns} = socket) do
    debug ev, params
    SubscriptionService.update assigns, %{last_read: params["last_read"]}
    {:noreply, socket}
  end

  # default unknown handler
  def handle_in(event, params, socket) do
    Logger.warn "UserChannel.handle_in unknown event: #{inspect event}, params: #{inspect params}"
    {:noreply, socket}
  end

  ###############
  # Info messages

  def handle_info(:after_join, socket) do
    debug "after_join", socket.assigns
    {:noreply, socket}
  end

  def handle_info(%Broadcast{topic: _, event: "room:update:name" = event, payload: payload}, socket) do
    debug event, payload
    push socket, event, payload
    # socket.endpoint.unsubscribe(CC.chan_room <> payload[:old_name])
    {:noreply, assign(socket, :subscribed, [payload[:new_name] | List.delete(socket.assigns[:subscribed], payload[:old_name])])}
  end
  def handle_info(%Broadcast{topic: _, event: "room:update:list" = event, payload: payload}, socket) do
    debug event, payload
    {:noreply, update_rooms_list(socket)}
  end
  def handle_info(%Broadcast{topic: "room:" <> room, event: "message:new" = event, payload: payload}, socket) do
    debug event, payload, inspect(socket.assigns)
    assigns = socket.assigns
    user_id = assigns.user_id
    if room in assigns.subscribed do
      channel = Helpers.get_by(Channel, :name, room)
      Logger.warn "in the room ... #{user_id}, room: #{inspect room}"
      # unless channel.id == assigns.channel_id and assigns.user_state != "idle" do
      if channel.id != assigns.channel_id or assigns.user_state == "idle" do
        if channel.type == 2 do
          Logger.warn "private channel ..."
          push_update_direct_message(%{channel_id: channel.id}, socket)
        end
        Logger.warn "updating unreads"
        update_has_unread(channel, socket)
      end
    end
    {:noreply, socket}
  end

  def handle_info(%Broadcast{topic: _, event: "user:action" = event, payload: %{action: "owner"} = payload}, %{assigns: assigns} = socket) do
    debug event, payload
    current_user = Helpers.get_user! assigns.user_id
    user = Helpers.get_user! payload.user_id
    channel = Helpers.get!(Channel, assigns.channel_id)
    user_info = FlexBarService.user_info channel, view_mode: true
    if Flex.open? assigns.flex, assigns.channel_id, "Members List" do
      html1 = Helpers.render(FlexBarView, "user_card_actions.html", current_user: current_user, channel_id: assigns.channel_id, user: user, user_info: user_info)
      push socket, "code:update", %{html: html1, selector: ~s(.user-view nav[data-username="#{user.username}"]), action: "html"}
    end
    {:noreply, socket}
  end

  def handle_info(%Broadcast{topic: _, event: "user:action" = event, payload:
      %{action: action} = payload}, %{assigns: assigns} = socket) when action in ~w(block) do
    debug event, payload, "assigns: #{inspect assigns}"
    current_user = Helpers.get_user! assigns.user_id
    user = Helpers.get_user! payload.user_id
    channel = Helpers.get!(Channel, assigns.channel_id)
    if Flex.open? assigns.flex, assigns.channel_id, "User Info" do
      # debug event, payload, action <> " open"
      user_info = FlexBarService.user_info channel, direct: true
      html1 = Helpers.render(FlexBarView, "user_card_actions.html", current_user: current_user, channel_id: assigns.channel_id, user: user, user_info: user_info)
      push socket, "code:update", %{html: html1, selector: ~s(.user-view nav[data-username="#{user.username}"]), action: "html"}
    else
      # debug event, payload, "closed"
    end
    {:noreply, socket}
  end

  def handle_info(%Broadcast{topic: _, event: "user:action" = event, payload:
      %{action: action} = payload}, %{assigns: assigns} = socket) when action in ~w(mute moderator owner) do
    debug event, payload
    current_user = Helpers.get_user! assigns.user_id
    user = Helpers.get_user! payload.user_id
    channel = Helpers.get!(Channel, assigns.channel_id)
    if Flex.open? assigns.flex, assigns.channel_id, "Members List" do
      # debug event, payload, action <> " open"
      user_info = FlexBarService.user_info channel, view_mode: true
      html1 = Helpers.render(FlexBarView, "user_card_actions.html", current_user: current_user, channel_id: assigns.channel_id, user: user, user_info: user_info)
      push socket, "code:update", %{html: html1, selector: ~s(.user-view nav[data-username="#{user.username}"]), action: "html"}

      if action == "mute" do
        html2 = Helpers.render(FlexBarView, "users_list_item.html", channel_id: assigns.channel_id, user: user)
        push socket, "code:update", %{html: html2, selector: ~s(.user-card-room[data-status-name="#{user.username}"]), action: "html"}
      end
    else
      # debug event, payload, "closed"
    end
    {:noreply, socket}
  end

  def handle_info(%Broadcast{topic: _, event: "user:action" = event, payload: %{action: "removed"} = payload}, %{assigns: assigns} = socket) do
    debug event, payload, "assigns: #{inspect assigns}"
    # current_user = Helpers.get_user! assigns.user_id
    user = Helpers.get_user! payload.user_id
    if Flex.open? assigns.flex, assigns.channel_id, "Members List" do
      debug event, payload, "removed open"

      push socket, "code:update", %{selector: ~s(.user-card-room[data-status-name='#{user.username}']), action: "remove"}
      push socket, "code:update", %{selector: ".flex-tab-container .user-view", action: "addClass", html: "animated-hidden"}
    else
      debug event, payload, "closed"
    end
    {:noreply, socket}
  end
  def handle_info(%Broadcast{topic: _, event: "user:action" = event, payload: %{action: "unhide"} = payload}, %{assigns: assigns} = socket) do
    debug event, payload, "assigns: #{inspect assigns}"

    UserSocket.push_rooms_list_update(socket, payload.channel_id, payload.user_id)

    {:noreply, socket}
  end
  def handle_info(%Broadcast{topic: _, event: "user:entered" = event, payload: %{user: user} = payload}, %{assigns: %{user: user} = assigns} = socket) do
    debug event, payload, "assigns: #{inspect assigns}"
    old_channel_id = assigns[:channel_id]
    channel_id = payload[:channel_id]
    socket = %{assigns: assigns} = assign(socket, :channel_id, channel_id)
    fl = assigns[:flex]
    cond do
      Flex.open?(fl, channel_id) ->
        Flex.show(fl, channel_id)
      old_channel_id && Flex.open?(fl, old_channel_id) ->
        push socket, "flex:close", %{}
      true ->
        nil
    end
    # UserSocket.push_message_box(socket, socket.assigns.channel_id, socket.assigns.user_id)
    {:noreply, socket}
  end

  def handle_info(%Broadcast{topic: _, event: "room:delete" = event, payload: payload}, socket) do
    debug event, payload
    room = payload.room
    if Enum.any?(socket.assigns[:subscribed], &(&1 == room)) do
      update_rooms_list(socket)
      {:noreply, assign(socket, :subscribed, List.delete(socket.assigns[:subscribed], room))}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:flex, :open, ch, tab, nil, params} = msg, socket) do
    debug inspect(msg), "nil"
    resp = FlexBarService.handle_flex_callback(:open, ch, tab, nil, socket, params)
    push socket, "flex:open", Enum.into([title: tab], resp)
    {:noreply, socket}
  end
  def handle_info({:flex, :open, ch, tab, args, params} = msg, socket) do
    debug inspect(msg), "args"
    resp = FlexBarService.handle_flex_callback(:open, ch, tab, args[tab], socket, params)
    push socket, "flex:open", Enum.into([title: tab], resp)
    {:noreply, socket}
  end
  def handle_info({:flex, :close, _ch, _tab, _, _params} = msg, socket) do
    debug inspect(msg), ""
    push socket, "flex:close", %{}
    {:noreply, socket}
  end

  def handle_info({:update_mention, channel_id, user_id} = ev, socket) do
    debug "upate_mention", ev
    channel = Helpers.get!(Channel, channel_id)
    with [sub] <- Repo.all(Subscription.get(channel_id, user_id)),
         open  <- Map.get(sub, :open),
         false <- socket.assigns.user_state == "active" and open,
         count <- ChannelService.get_unread(channel_id, user_id),
      do: push(socket, "room:mention", %{room: channel.name, unread: count})
    {:noreply, socket}
  end

  def handle_info({:update_direct_message, channel_id, user_id} = ev, socket) do
    debug "upate_direct_message", ev
    channel = Helpers.get!(Channel, channel_id)
    with [sub] <- Repo.all(Subscription.get(channel_id, user_id)),
         _ <- Logger.warn("update_direct_message unread: #{sub.unread}"),
         open  <- Map.get(sub, :open),
         false <- socket.assigns.user_state == "active" and open,
         count <- ChannelService.get_unread(channel_id, user_id),
      do: push(socket, "room:mention", %{room: channel.name, unread: count})
    {:noreply, socket}
  end

  # Default case to ignore messages we are not interested in
  def handle_info(%Broadcast{}, socket) do
    {:noreply, socket}
  end

  ###############
  # Helpers

  defp subscribe(channels, socket) do
    # debug inspect(channels), ""
    Enum.reduce channels, socket, fn channel, acc ->
      subscribed = acc.assigns[:subscribed]
      if channel in subscribed do
        acc
      else
        socket.endpoint.subscribe(CC.chan_room <> channel)
        assign(acc, :subscribed, [channel | subscribed])
      end
    end
  end

  # assigns[:flex] %{open: %{channel_id => "Info"} }

  defp toggle_flex(%{assigns: %{flex: fl} = assigns} = socket, tab, params) do
    assign socket, :flex, Flex.toggle(fl, assigns[:channel_id], tab, params)
  end

  defp open_flex_item(%{assigns: %{flex: fl} = assigns} = socket, tab, params) do
    debug inspect(fl), tab, inspect(params)
    assign socket, :flex, Flex.open(fl, assigns[:channel_id], tab, params["args"], params)
  end

  defp update_rooms_list(%{assigns: assigns} = socket) do
    debug "", inspect(assigns)
    html = SideNavService.render_rooms_list(assigns[:channel_id], assigns[:user_id])
    push socket, "update:rooms", %{html: html}
    socket
  end

  defp clear_unreads(socket) do
    Channel
    |> Helpers.get(socket.assigns.channel_id)
    |> Map.get(:name)
    |> clear_unreads(socket)
  end

  defp clear_unreads(room, %{assigns: assigns} = socket) do
    # Logger.warn "room: #{inspect room}, assigns: #{inspect assigns}"
    ChannelService.set_has_unread(assigns.channel_id, assigns.user_id, false)
    push socket, "code:update", %{selector: ".link-room-" <> room, html: "has-unread", action: "removeClass"}
    push socket, "code:update", %{selector: ".link-room-" <> room, html: "has-alert", action: "removeClass"}
  end

  defp update_has_unread(%{id: channel_id, name: room}, %{assigns: assigns} = socket) do
    has_unread = ChannelService.get_has_unread(channel_id, assigns.user_id)
    Logger.warn "has_unread: #{inspect has_unread}"
    unless has_unread do
      ChannelService.set_has_unread(channel_id, assigns.user_id, true)
      push socket, "code:update", %{selector: ".link-room-" <> room, html: "has-unread", action: "addClass"}
      push socket, "code:update", %{selector: ".link-room-" <> room, html: "has-alert", action: "addClass"}
    end
  end
end
