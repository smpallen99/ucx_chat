defmodule UcxChat.ClientChannel do
  use Phoenix.Channel
  alias Phoenix.Socket.Broadcast
  alias UcxChat.{Subscription, Repo, Flex, FlexBarService}
  use UcxChat.ChannelApi

  import Ecto.Query

  require Logger

  def join_room(client_id, _room) do
    Logger.warn ("...join_room client_id: #{inspect client_id}")
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
    {:noreply, subscribe([room], socket)}
  end
  def handle_out("room:leave" = ev, msg, socket) do
    %{room: room} = msg
    debug ev, msg
    socket.endpoint.unsubscribe("ucxchat:room-" <> room)
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

end
