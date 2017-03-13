defmodule UcxChat.TypingChannelController do
  use UcxChat.Web, :channel_controller

  # import UcxChat.ChannelController
  alias UcxChat.{TypingAgent, MessageService}

  require Logger

  # @module __MODULE__
  # @module_name inspect(@module)

  def create(%{assigns: %{channel_id: channel_id, user_id: user_id, username: username, room: room}} = socket, _params) do
    # Logger.warn "#{@module_name} create params: #{inspect params}, socket: #{inspect socket}"
    TypingAgent.start_typing(channel_id, user_id, username)
    MessageService.update_typing(channel_id, room)
    {:noreply, socket}
  end

  def delete(socket, _params) do

    # TypingAgent.stop_typing(channel_id, user_id)
    # MessageService.update_typing(channel_id, room)

    {:noreply, socket}
  end

end
