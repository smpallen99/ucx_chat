defmodule UcxChat.ClientChannel do
  use Phoenix.Channel
  use UcxChat.ChannelApi

  import Ecto.Query

  alias Phoenix.Socket.Broadcast
  alias UcxChat.{Subscription, Repo, Flex, FlexBarService, ChannelService}
  alias UcxChat.{AccountView, Account, AdminService}
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger

  def join_room(client_id, room) do
    Logger.warn ("...join_room client_id: #{inspect client_id}")
    UcxChat.Endpoint.broadcast!("client:#{client_id}", "room:join", %{room: room, client_id: client_id})
  end

  def leave_room(client_id, room) do
    UcxChat.Endpoint.broadcast!("client:#{client_id}", "room:leave", %{room: room, client_id: client_id})
  end

  # intercept ~w(room:join room:leave)
  intercept ["room:join", "room:leave"]

  def join("client:" <> client_id, params, socket) do
    debug("client:" <> client_id, params)
    new_assigns = params |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end) |> Enum.into(%{})
    socket =
      socket
      |> struct(assigns: Map.merge(new_assigns, socket.assigns))
      |> assign(:subscribed, socket.assigns[:subscribed] || [])
      |> assign(:flex, Flex.new())
    socket =
      Repo.all(from s in Subscription, where: s.client_id == ^client_id, preload: [:channel, :client])
      |> Enum.map(&(&1.channel.name))
      |> subscribe(socket)
    {:ok, socket}
  end

  ###############
  # Outgoing Incoming Messages

  def handle_out("room:join" = ev, msg, socket) do
    %{room: room} = msg
    debug ev, msg
    update_rooms_list(socket)
    {:noreply, subscribe([room], socket)}
  end
  def handle_out("room:leave" = ev, msg, socket) do
    %{room: room} = msg
    debug ev, msg
    socket.endpoint.unsubscribe("ucxchat:room-" <> room)
    update_rooms_list(socket)
    {:noreply, assign(socket, :subscribed, List.delete(socket.assigns[:subscribed], room))}
  end

  ###############
  # Incoming Messages

  def handle_in("subscribe" = ev, params, socket) do
    debug ev, params
    {:noreply, socket}
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
    #  $('.main-content').html(resp.html)
    html = Helpers.render(AccountView, "account_preferences.html", user: user, account_changeset: account_cs)
    push socket, "code:update", %{html: html, selector: ".main-content", action: "html"}

    html = Helpers.render(AccountView, "account_flex.html")
    {:reply, {:ok, %{html: html}}, socket}
  end
  def handle_in("side_nav:open" = ev, %{"page" => "admin"} = params, socket) do
    debug ev, params

    user = Helpers.get_user!(socket)
    # account_cs = Config.changeset(user.account, %{})
    #  $('.main-content').html(resp.html)
    # html = Helpers.render(AccountView, "account_preferences.html", user: user, account_changeset: account_cs)
    # push socket, "code:update", %{html: html, selector: ".main-content", action: "html"}

    html = Helpers.render(UcxChat.AdminView, "admin_flex.html", user: user)
    {:reply, {:ok, %{html: html}}, socket}
  end

  def handle_in("side_nav:close" = ev, params, socket) do
    debug ev, params

    {:noreply, socket}
  end

  def handle_in("account:preferences:save" = ev, params, socket) do
    debug ev, params
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
          {:ok, %{success: "Account updated successfully"}}
        {:error, _cs} ->
          {:ok, %{error: "There a problem updating your account."}}
      end
    {:reply, resp, socket}
  end

  @links ~w(preferences profile)
  def handle_in(ev = "account_link:click:" <> link, params, socket) when link in @links do
    debug ev, params
    html = Helpers.render(AccountView, "account_#{link}.html")
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
          # channel = Helpers.get!(Channel, socket.assigns[:channel_id])
          # chatd = ChatDat.new user, channel, []
          # html =
          #   "rooms_list.html"
          #   |> UcxChat.SideNavView.render(chatd: chatd)
          #   |> Phoenix.HTML.safe_to_string
          push socket, "window:reload", %{}
          {:ok, %{}}
        {:error, _} ->
          {:error, %{error: "There was a problem switching modes"}}
      end
    {:reply, resp, socket}
  end

  @links ~w(info general message permissions)
  def handle_in(ev = "admin_link:click:" <> link, params, socket) when link in @links do
    debug ev, params
    user = Helpers.get_user! socket
    html = AdminService.render user, link, "#{link}.html"
    push socket, "code:update", %{html: html, selector: ".main-content", action: "html"}
    {:noreply, socket}
  end

  def handle_in(ev = "admin:" <> link, params, socket) do
    debug ev, params
    # user = Helpers.get_user! socket
    AdminService.handle_in(link, params, socket)
  end


  # default unknown handler
  def handle_in(event, params, socket) do
    Logger.warn "ClientChannel.handle_in unknown event: #{inspect event}, params: #{inspect params}"
    {:noreply, socket}
  end

  ###############
  # Info messages

  def handle_info(%Broadcast{topic: _, event: "room:update:name" = event, payload: payload}, socket) do
    debug event, payload
    push socket, event, payload
    socket.endpoint.unsubscribe("ucxchat:room-" <> payload[:old_name])
    {:noreply, assign(socket, :subscribed, [payload[:new_name] | List.delete(socket.assigns[:subscribed], payload[:old_name])])}
  end

  def handle_info(%Broadcast{topic: _, event: "user:entered" = event, payload: payload}, %{assigns: assigns} = socket) do
    debug event, payload
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
    {:noreply, socket}
  end

  def handle_info({:flex, :open, ch, tab, nil, params} = msg, socket) do
    debug inspect(msg), ""
    resp = FlexBarService.handle_flex_callback(:open, ch, tab, nil, socket, params)
    push socket, "flex:open", Enum.into([title: tab], resp)
    {:noreply, socket}
  end
  def handle_info({:flex, :open, ch, tab, args, params} = msg, socket) do
    debug inspect(msg), ""
    resp = FlexBarService.handle_flex_callback(:open, ch, tab, args[tab], socket, params)
    push socket, "flex:open", Enum.into([title: tab], resp)
    {:noreply, socket}
  end
  def handle_info({:flex, :close, _ch, _tab, _, _params} = msg, socket) do
    debug inspect(msg), ""
    push socket, "flex:close", %{}
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
        socket.endpoint.subscribe("ucxchat:room-" <> channel)
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
    html = ChannelService.render_rooms(assigns[:channel_id], assigns[:client_id])
    push socket, "update:rooms", %{html: html}
    socket
  end

end
