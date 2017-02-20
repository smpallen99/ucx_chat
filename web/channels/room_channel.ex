defmodule UcxChat.RoomChannel do
  @moduledoc """
  Handle incoming and outgoing Subscription messages
  """
  use Phoenix.Channel
  alias UcxChat.{Repo, Message, MessageService, ChannelService, TypingAgent, MessagePopupService, SlashCommandsService}

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
  def join("ucxchat:room-" <> room, msg, socket) do
    Logger.warn "join room-#{room}, msg: #{inspect msg}"
    send self(), {:after_join, msg}
    {:ok, socket}
  end
  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"]}
    push socket, "join", %{status: "connected"}
    socket = Phoenix.Socket.assign(socket, :user_id, msg["user_id"])
    {:noreply, socket}
  end

  ##########
  # Outgoing message handlers

  def handle_out(_event, msg, socket) do
    # Logger.error "handle_out topic: #{event}, msg: #{inspect msg}"
    {:reply, {:ok, msg}, socket}
  end

  ##########
  # Incoming message handlers

  def handle_in(pattern, %{"params" => params, "ucxchat" =>  ucxchat}, socket) do
    Logger.warn "new handle_in params: #{inspect params}, ucxchat: #{inspect ucxchat}"
    UcxChat.ChannelRouter.route(socket, pattern, params, ucxchat)
  end

  def handle_in("message", %{"message" => "/" <> slashcommand} = msg, socket) do
    SlashCommandsService.handle_in(slashcommand, msg, socket)
  end

  def handle_in("message", %{} = msg, socket) do
    # Logger.warn "handle_in message, msg: #{inspect msg}"
    Logger.warn "handle_in message, socket: #{inspect socket}"
    MessageService.new_message(msg["channel_id"], msg["message"], msg["client_id"], msg["room"])
    {:noreply, socket}
  end

  def handle_in("messages:" <> cmd, msg, socket) do
    res = MessageService.handle_in(cmd, msg)
    {:reply, res, socket}
  end

  def handle_in("/typing/start", %{"channel_id" => channel_id,
    "client_id" => client_id, "nickname" => nickname, "room" => room} = msg, socket) do
    Logger.debug "typing:start client_id: #{inspect client_id}, nickname: #{inspect nickname}"
    Logger.debug "msg: #{inspect msg}, socket: #{inspect socket}"
    TypingAgent.start_typing(channel_id, client_id, nickname)
    MessageService.update_typing(channel_id, room)
    {:noreply, socket}
  end

  def handle_in("/typing/stop", %{"channel_id" => channel_id, "client_id" => client_id, "room" => room} = msg, socket) do
    Logger.warn "typing:stop msg: #{inspect msg}, socket: #{inspect socket}"
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
    resp = UcxChat.FlexBarService.handle_click(mod, msg)
    {:reply, resp, socket}
  end

  def handle_in("flex_bar:" <> mod, msg, socket) do
    Logger.warn "flex-bar mod: #{inspect mod}, msg: #{inspect msg}"
    resp = UcxChat.FlexBarService.handle_in(mod, msg)
    {:reply, resp, socket}
  end

  def handle_in("message_popup:" <> cmd, msg, socket) do
    resp = UcxChat.MessagePopupService.handle_in(cmd, msg)
    {:reply, resp, socket}
  end

  def handle_in("message_cog:" <> cmd, msg, socket) do
    resp = case UcxChat.MessageCogService.handle_in(cmd, msg) do
      {:nil, msg} ->
        {:ok, msg}
      {event, msg} ->
        Logger.warn "msg cog ret event: #{inspect event}, msg: #{inspect msg}"
        broadcast! socket, event, %{}
        {:ok, msg}
    end
    {:reply, resp, socket}
  end

  # default case
  def handle_in(topic, msg, socket) do
    Logger.warn "RoomChannel no handler for: topic: #{topic}, msg: #{inspect msg}"
    {:noreply, socket}
  end


  #########
  # Private

end
