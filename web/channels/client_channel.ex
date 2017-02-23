defmodule UcxChat.ClientChannel do
  use Phoenix.Channel
  alias Phoenix.Socket.Broadcast
  alias UcxChat.{Subscription, Repo, Channel}

  import Ecto.Query

  require Logger

  def join_room(client_id, room) do
    Logger.warn ("...join_room client_id: #{inspect client_id}")
    UcxChat.Endpoint.broadcast("client:#{client_id}", "room:join", %{room: room, client_id: client_id})
  end

  def leave_room(client_id, room) do
    res = UcxChat.Endpoint.broadcast!("client:#{client_id}", "room:leave", %{room: room, client_id: client_id})
    Logger.warn ("...leave_room client_id: #{inspect client_id}, res: #{inspect res}")
    res
  end

  # intercept ~w(room:join room:leave)
  intercept ["room:join", "room:leave"]

  def join("client:" <> client_id, params, socket) do
    Logger.warn "......... client channel join client_id: #{inspect client_id}"
    # subs = Repo.all(from s in Subscription, where: s.client_id == ^client_id, preload: [:channel, :client])
    # Logger.info "... client: #{inspect subs |> hd |> Map.get(:client) |> Map.get(:nickname)}"
    socket =
      assign(socket, :subscribed, socket.assigns[:subscribed] || [])
      Repo.all(from s in Subscription, where: s.client_id == ^client_id, preload: [:channel, :client])
      |> Enum.map(&(&1.channel.name))
      |> subscribe(socket)
    {:ok, socket}
  end

  def handle_out("room:join", msg, socket) do
    %{room: room} = msg
    Logger.warn  "----handle_out room:join:" <> room
    {:noreply, subscribe([room], socket)}
  end
  def handle_out("room:leave", msg, socket) do
    %{room: room} = msg
    Logger.warn "--- handle_out room:leave:" <> room
    socket.endpoint.unsubscribe("ucxchat:room-" <> room)
    {:noreply, assign(socket, :subscribed, List.delete(socket.assigns[:subscribed], room))}
  end

  def handle_in("subscribe", params, socket) do
    Logger.warn "........... client channel subscribe: #{inspect params}"
    # socket.endpoint.subscribe("ucxchat:*")
    {:noreply, socket}
  end


  def handle_info(%Broadcast{topic: _, event: "room:update:name" = event, payload: payload}, socket) do
    Logger.warn "...........broadcast, payload: #{inspect payload}, socket: #{inspect socket}"
    push socket, event, payload
    socket.endpoint.unsubscribe("ucxchat:room-" <> payload[:old_name])
    {:noreply, assign(socket, :subscribed, [payload[:new_name] | List.delete(socket.assigns[:subscribed], payload[:old_name])])}
  end

  def handle_info(%Broadcast{}, socket) do
    {:noreply, socket}
  end

  defp subscribe(channels, socket) do
    Enum.reduce channels, socket, fn channel, acc ->
      subscribed = socket.assigns[:subscribed]
      if channel in subscribed do
        acc
      else
        socket.endpoint.subscribe("ucxchat:room-" <> channel)
        assign(acc, :subscribed, [channel | subscribed])
      end
    end
  end
end
