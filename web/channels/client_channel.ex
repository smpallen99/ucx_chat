defmodule UcxChat.ClientChannel do
  use Phoenix.Channel
  alias Phoenix.Socket.Broadcast
  alias UcxChat.{Subscription, Repo, Channel}

  import Ecto.Query

  require Logger

  def join("client:" <> client_id, params, socket) do
    Logger.warn "......... client channel join client_id: #{inspect client_id}"
    subs = Repo.all(from s in Subscription, where: s.client_id == ^client_id, preload: [:channel, :client])
    Logger.info "... client: #{inspect subs |> hd |> Map.get(:client) |> Map.get(:nickname)}"
    for sub <- subs do
      Logger.info ".... name: #{inspect sub.channel.name}"
      UcxChat.Endpoint.subscribe("ucxchat:room-" <> sub.channel.name)
    end
    {:ok, socket}
  end

  def handle_in("subscribe", params, socket) do
    Logger.warn "........... client channel subscribe: #{inspect params}"
    # socket.endpoint.subscribe("ucxchat:*")
    {:noreply, socket}
  end

  def handle_info(%Broadcast{topic: _, event: "room:update:name" = event, payload: payload}, socket) do
    Logger.warn "...........broadcast, payload: #{inspect payload}, socket: #{inspect socket}"
    push socket, event, payload
    {:noreply, socket}
  end
  def handle_info(_, socket) do
    {:noreply, socket}
  end
end
