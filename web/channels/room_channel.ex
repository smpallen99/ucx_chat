defmodule UcxChat.RoomChannel do
  @moduledoc """
  Handle incoming and outgoing ClientChannel messages
  """
  use Phoenix.Channel
  alias UcxChat.{Repo, Message}
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

  # def handle_in("client:btn_press", msg, socket) do
  #   # Logger.error "handle_in btn_press msg: #{inspect msg}"
  #   {:noreply, socket}
  # end
  def handle_in("message", %{"nickname" => nickname, "channel_id" => cid, "message" => message, "client_id" => client_id, "room" => room} = msg, socket) do
    Logger.warn "handle_in message, msg: #{inspect msg}"
    message = Message.changeset(%Message{}, %{channel_id: cid, client_id: client_id, body: message})
    |> Repo.insert!
    msg = %{id: message.id, nickname: nickname, date: "February 11, 2017", timestamp: 111111, message: message.body, client_id: client_id}
    UcxChat.Endpoint.broadcast("ucxchat:room-" <> room, "message", msg)
    {:noreply, socket}
  end
  def handle_in(topic, msg, socket) do
    Logger.warn "handle_in topic: #{topic}, msg: #{inspect msg}"
    {:noreply, socket}
  end

  #########
  # Private

end
