defmodule UcxChat.RoomChannelController do
  use UcxChat.Web, :channel_controller

  alias UcxChat.{ChannelService}
  require Logger

  def show(%{assigns: assigns} = socket, params) do
    # Logger.warn "room channel_controller params: #{inspect params}, socket.assigns: #{inspect socket.assigns}"
    reply = ChannelService.open_room(assigns[:user_id], params["room_id"], assigns[:room], params["display_name"])
    {:reply, {:ok, reply}, socket}
  end

  def favorite(socket, _param) do
    assigns = socket.assigns
    resp = ChannelService.toggle_favorite(assigns[:user_id], assigns[:channel_id])
    {:reply, resp, socket}
  end

  # create a new direct
  def create(%{assigns: assigns} = socket, params) do
    resp = ChannelService.add_direct(params["username"], assigns[:user_id], assigns[:channel_id])
    {:reply, resp, socket}
  end
end
