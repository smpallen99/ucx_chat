defmodule UcxChat.SystemChannel do
  use Phoenix.Channel
  use UcxChat.ChannelApi
  alias UcxChat.Presence
  alias UcxChat.ServiceHelpers, as: Helpers

  # import Ecto.Query

  @blur_timer 5 * 60 * 1000
  # @blur_timer 10 * 1000

  # import Ecto.Query

  # alias Phoenix.Socket.Broadcast
  # alias UcxChat.{Subscription, Repo, Flex, FlexBarService, ChannelService}
  # alias UcxChat.{AccountView, Account, AdminService}
  # alias UcxChat.ServiceHelpers, as: Helpers
  require UcxChat.ChatConstants, as: CC

  require Logger

  intercept ["presence_diff"]

  def join(ev = CC.chan_system(), params, socket) do
    debug(ev, params)
    send(self(), :after_join)
    :ok = UcxChat.ChannelMonitor.monitor(:chan_system, self(), {__MODULE__, :leave, [socket.assigns.user_id]})

    {:ok, socket}
  end

  def leave(pid, user_id) do
    Logger.warn "user_id: #{inspect user_id} left the channel"
    UcxChat.Presence.untrack(pid, CC.chan_system(), user_id)
    UcxChat.PresenceAgent.unload(user_id)
  end

  def handle_out(ev = "presence_diff", params, socket) do
    debug(ev, params)
    # Logger.warn "presence_diff params: #{inspect params}, assigns: #{inspect socket.assigns}"
    push socket, ev, params
    {:noreply, socket}
  end

  ###############
  # handle_in

  def handle_in(ev = "status:set:" <> status, params, socket) do
    debug ev, params
    # Logger.warn "status:set socket: #{inspect socket}"
    UcxChat.PresenceAgent.put(socket.assigns.user_id, status)
    update_status socket, status
    # Presence.update socket, socket.assigns.user_id, %{status: status}
    {:noreply, socket}
  end
  def handle_in(ev = "state:blur", params, socket) do
    debug ev, params
    # TODO: move this blur timer to a configuration item
    ref = Process.send_after self(), :blur_timeout, @blur_timer
    {:noreply, assign(socket, :blur_ref, ref)}
  end
  def handle_in(ev = "state:focus", params, socket) do
    debug ev, params
    # TODO: move this blur timer to a configuration item
    socket =
      case socket.assigns[:blur_ref] do
        nil ->
          # Logger.warn "focus socket: #{inspect socket}"
          update_status socket, "online"
          # Presence.update socket, socket.assigns.user_id, %{status: "online"}
          socket
        ref ->
          Process.cancel_timer ref
          assign(socket, :blur_ref, nil)
      end
    {:noreply, socket}
  end

  # default unknown handler
  def handle_in(event, params, socket) do
    Logger.warn "SystemChannel.handle_in unknown event: #{inspect event}, params: #{inspect params}, assigns: #{inspect socket.assigns}"
    {:noreply, socket}
  end

  ###############
  # Info messages

  def handle_info(:blur_timeout, socket) do
    # Logger.warn "blur_timeout, socket: #{inspect socket}"
    update_status socket, "away"
    # Presence.update socket, socket.assigns.user_id, %{status: "away"}
    {:noreply, assign(socket, :blur_ref, nil)}
  end

  def handle_info(:after_join, socket) do
    list = Presence.list(socket)
    # Logger.warn "after join presence list: #{inspect list}"
    push socket, "presence_state", list
    user = Helpers.get_user!(socket.assigns.user_id)
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      # online_at: :os.system_time(:milli_seconds),
      status: "online",
      username: user.username
    })
    {:noreply, socket}
  end

  def update_status(%{assigns: %{user_id: user_id, username: username}} = socket, status) do
    case UcxChat.PresenceAgent.get_and_update_presence(user_id, status) do
      ^status -> Presence.update socket, user_id, %{status: status, username: username}
      _ ->  nil
    end
  end
end
