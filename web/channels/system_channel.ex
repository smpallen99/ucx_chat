defmodule UcxChat.SystemChannel do
  use Phoenix.Channel
  use UcxChat.ChannelApi
  alias UcxChat.Presence

  # import Ecto.Query

  # alias Phoenix.Socket.Broadcast
  # alias UcxChat.{Subscription, Repo, Flex, FlexBarService, ChannelService}
  # alias UcxChat.{AccountView, Account, AdminService}
  # alias UcxChat.ServiceHelpers, as: Helpers
  require UcxChat.ChatConstants, as: CC

  require Logger

  def join(ev = CC.chan_system(), params, socket) do
    debug(ev, params)
    send(self(), :after_join)

    {:ok, socket}
  end

  ###############
  # handle_in

  # default unknown handler
  def handle_in(event, params, socket) do
    Logger.warn "SystemChannel.handle_in unknown event: #{inspect event}, params: #{inspect params}"
    {:noreply, socket}
  end

  ###############
  # Info messages

  def handle_info(:after_join, socket) do
    list = Presence.list(socket)
    Logger.warn "after join presence list: #{inspect list}"
    push socket, "presence_state", list
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(:os.system_time(:milli_seconds))
    })
    {:noreply, socket}
  end
end
