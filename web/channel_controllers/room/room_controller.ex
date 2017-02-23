defmodule UcxChat.RoomChannelController do
  use UcxChat.Web, :channel_controller

  alias UcxChat.{ChannelService}

  def show(socket, params) do
    client_id = socket.assigns[:client_id]
    room = socket.assigns[:room]
    room_id = params["room_id"]
    reply = ChannelService.open_room(client_id, params["room_id"], room, params["display_name"])
    {:reply, {:ok, reply}, socket}
  end

  def favorite(socket, param) do
    assigns = socket.assigns
    resp = ChannelService.toggle_favorite(assigns[:client_id], assigns[:channel_id])
    {:reply, resp, socket}
  end

  # create a new direct
  def create(%{assigns: assigns} = socket, params) do
    resp = ChannelService.add_direct(params["nickname"], assigns[:client_id], assigns[:channel_id])
    {:reply, resp, socket}
  end
end
