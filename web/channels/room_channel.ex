defmodule UcxChat.RoomChannel do
  @moduledoc """
  Handle incoming and outgoing ClientChannel messages
  """
  use Phoenix.Channel
  alias UcxChat.{Repo, Message, MessageService, ChannelService, TypingAgent}

  require Logger

  ############
  # API

  def user_join(nil), do: Logger.warn "join for nil username"
  def user_join(username, room) do
    UcxChat.Endpoint.broadcast "ucxchat:room-#{room}", "user:join", %{username: username}
  end

  def user_leave(nil), do: Logger.warn "leave for nil username"
  def user_leave(username, room) do
    UcxChat.Endpoint.broadcast "ucxchat:room-#{room}", "user:leave", %{username: username}
  end

  ############
  # Socket stuff
  def join("ucxchat:room-" <> room, _params, socket) do
    Logger.debug "channel messaging join room-#{room}"

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

  def handle_in("typing:start", %{"channel_id" => channel_id,
    "client_id" => client_id, "nickname" => nickname, "room" => room}, socket) do
    TypingAgent.start_typing(channel_id, client_id, nickname)
    MessageService.update_typing(channel_id, room)
    {:noreply, socket}
  end

  def handle_in("typing:stop", %{"channel_id" => channel_id, "client_id" => client_id, "room" => room}, socket) do
    TypingAgent.stop_typing(channel_id, client_id)
    MessageService.update_typing(channel_id, room)

    {:noreply, socket}
  end

  def handle_in("room:open", msg, socket) do
    reply = ChannelService.open_room(msg["client_id"], msg["room"], msg["old_room"])
    {:reply, {:ok, reply}, socket}
  end

  # default case
  def handle_in(topic, msg, socket) do
    Logger.warn "handle_in topic: #{topic}, msg: #{inspect msg}"
    {:noreply, socket}
  end

  # def handle_in("channels:get", message, socket) do
  #   channel_id = message["channel_id"]
  #   client_id = message["client_id"]
  #   channels =
  #     Channel
  #     |> where([c], c.client_id == ^client_id)
  #     |> Repo.all
  #     |> Enum.map(fn chan ->
  #       %{active: false, unread: false, alert: false, user_status: "off-line",
  #         room_icon: "icon-hash", archived: false, name: chan.name}
  #     end)
  #   out_message = %{rooms: channels}
  #   {:reply, {:ok, out_message}}, socket}
  # end
  # def handle_in("message:get", message, socket) do
  #   channel_id = message["channel_id"]
  #   messages =
  #     Message
  #     |> where([m], m.channel_id == ^channel_id)
  #     |> join(:left, [m], c in assoc(m, :client))
  #     |> select([m,c], {m.id, m.body, m.updated_at, c.id, c.nickname})
  #     |> Repo.all
  #     |> Enum.map(fn {id, body, updated_at, client_id, nickname} ->
  #       create_message_message(id, body, updated_at, client_id, nickname)
  #     end)
  #   # UcxChat.Endpoint.broadcast("ucxchat:room-" <> message["room"], "message:list", %{messages: messages})
  #   {:reply, {:ok, %{messages: messages}}, socket}
  # end

  # def handle_in("message:new", %{"nickname" => nickname, "channel_id" => channel_id, "message" => message, "client_id" => client_id, "room" => room} = msg, socket) do
  #   Logger.warn "handle_in message:new, msg: #{inspect msg}"
  #   message = Message.changeset(%Message{}, %{channel_id: channel_id, client_id: client_id, body: message})
  #   |> Repo.insert!
  #   # msg = %{ts: %{day: 1, mo: 2, yr: 3}, id: message.id, nickname: nickname, date: "February 11, 2017", timestamp: 111111, message: message.body, client_id: client_id}
  #   # UcxChat.Endpoint.broadcast("ucxchat:room-" <> room, "message:single", msg)
  #   send_message_message(room, message, client_id, nickname)
  #   {:noreply, socket}
  # end
  # def handle_in(topic, msg, socket) do
  #   Logger.warn "handle_in topic: #{topic}, msg: #{inspect msg}"
  #   {:noreply, socket}
  # end

  # defp send_message_message(room, %{id: id, body: body, updated_at: updated_at}, client_id, nickname) do
  #   send_message_message(room, id, body, updated_at, client_id, nickname)
  # end
  # defp send_message_message(room, id, body, updated_at, client_id, nickname) do
  #   msg = create_message_message(id, body, updated_at, client_id, nickname)
  #   UcxChat.Endpoint.broadcast("ucxchat:room-" <> room, "message:list", %{messages: [msg]})
  # end
  # defp create_message_message(id, body, updated_at, client_id, nickname) do
  #   {{yr, mo, day}, {hr, min, sec}} = NaiveDateTime.to_erl(updated_at)
  #   ts = %{yr: yr, mo: mo, day: day, hr: hr, min: min, sec: sec}
  #   %{id: id, message: body, nickname: nickname, client_id: client_id, ts: ts}
  # end
  #########
  # Private

end
