defmodule UcxChat.RoomChannel do
  @moduledoc """
  Handle incoming and outgoing ClientChannel messages
  """
  use Phoenix.Channel
  alias UcxChat.{Repo, Message, MessageService, ChannelService, TypingAgent, MessagePopupService}

  require Logger

  ############
  # API

  def user_join(nil), do: Logger.warn "join for nil username"
  def user_join(username, room) do
    Logger.warn "user_join username: #{inspect username}, room: #{inspect room}"
    UcxChat.Endpoint.broadcast "ucxchat:room-#{room}", "user:join", %{username: username}
  end

  def user_leave(nil), do: Logger.warn "leave for nil username"
  def user_leave(username, room) do
    Logger.warn "user_leave username: #{inspect username}, room: #{inspect room}"
    UcxChat.Endpoint.broadcast "ucxchat:room-#{room}", "user:leave", %{username: username}
  end

  ############
  # Socket stuff
  def join("ucxchat:room-" <> room, params, socket) do
    Logger.warn "join room-#{room}, params: #{inspect params}"

    {:ok, socket}
  end

  ##########
  # Outgoing message handlers

  def handle_out(_event, msg, socket) do
    # Logger.error "handle_out topic: #{event}, msg: #{inspect msg}"
    {:reply, {:ok, msg}, socket}
  end

  ##########
  # Incoming message handlers

  def handle_in("message", %{} = msg, socket) do
    Logger.debug "handle_in message, msg: #{inspect msg}"
    MessageService.new_message(msg["channel_id"], msg["message"], msg["client_id"], msg["room"])
    {:noreply, socket}
  end

  def handle_in("messages:" <> cmd, msg, socket) do
    res = MessageService.handle_in(cmd, msg)
    {:reply, res, socket}
  end

  def handle_in("typing:start", %{"channel_id" => channel_id,
    "client_id" => client_id, "nickname" => nickname, "room" => room}, socket) do
    Logger.debug "typing:start client_id: #{inspect client_id}, nickname: #{inspect nickname}"
    TypingAgent.start_typing(channel_id, client_id, nickname)
    MessageService.update_typing(channel_id, room)
    {:noreply, socket}
  end

  def handle_in("typing:stop", %{"channel_id" => channel_id, "client_id" => client_id, "room" => room}, socket) do
    Logger.debug "typing:stop client_id: #{inspect client_id}"
    TypingAgent.stop_typing(channel_id, client_id)
    MessageService.update_typing(channel_id, room)

    {:noreply, socket}
  end

  def handle_in("room:open", msg, socket) do
    reply = ChannelService.open_room(msg["client_id"], msg["room"], msg["old_room"], msg["display_name"])
    {:reply, {:ok, reply}, socket}
  end

  def handle_in("room:favorite", msg, socket) do
    Logger.debug "room:favorite msg: #{inspect msg}"
    resp = ChannelService.toggle_favorite(msg["client_id"], msg["channel_id"])
    {:reply, resp, socket}
  end

  def handle_in("room:add-direct", msg, socket) do
    Logger.debug "room:add-direct msg: #{inspect msg}"
    resp = ChannelService.add_direct(msg["nickname"], msg["client_id"], msg["channel_id"])
    {:reply, resp, socket}
  end
  def handle_in("flex_bar:click:" <> mod, msg, socket) do
    resp = UcxChat.FlexBarService.handle_in(mod, msg)
    {:reply, resp, socket}
  end

  def handle_in("message_popup:" <> cmd, msg, socket) do
    resp = UcxChat.MessagePopupService.handle_in(cmd, msg)
    {:reply, resp, socket}
  end
  def handle_in("message_cog:" <> cmd, msg, socket) do
    resp = UcxChat.MessageCogService.handle_in(cmd, msg)
    {:reply, resp, socket}
  end

  # default case
  def handle_in(topic, msg, socket) do
    Logger.warn "handle_in topic: #{topic}, msg: #{inspect msg}"
    {:noreply, socket}
  end


  #########
  # Private

end
