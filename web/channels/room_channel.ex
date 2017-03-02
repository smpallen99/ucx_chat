defmodule UcxChat.RoomChannel do
  @moduledoc """
  Handle incoming and outgoing Subscription messages
  """
  use Phoenix.Channel
  use UcxChat.ChannelApi

  import Ecto.Query

  alias UcxChat.{Subscription, Repo, Channel}
  alias UcxChat.{ServiceHelpers}

  require UcxChat.ChatConstants, as: CC
  require Logger

  ############
  # API
  # intercept ["lobby:room:update:name"]

  def user_join(nil), do: Logger.warn "join for nil username"
  def user_join(username, room) do
    # Logger.warn "user_join username: #{inspect username}, room: #{inspect room}"
    UcxChat.Endpoint.broadcast CC.chan_room <> room, "user:join", %{username: username}
  end

  def user_leave(nil), do: Logger.warn "leave for nil username"
  def user_leave(username, room) do
    Logger.warn "user_leave username: #{inspect username}, room: #{inspect room}"
    UcxChat.Endpoint.broadcast CC.chan_room <> room, "user:leave", %{username: username}
  end

  ############
  # Socket stuff

  def join(CC.chan_room <> "lobby", msg, socket) do
    Logger.info "user joined lobby msg: #{inspect msg}, socket: #{inspect socket}"
    {:ok, socket}
  end

  def join(ev = CC.chan_room <> room, msg, socket) do
    debug ev, msg
    send self(), {:after_join, room, msg}
    {:ok, socket}
  end

  def handle_info({:after_join, room, msg}, socket) do
    Logger.warn "room channel after_join, room: #{inspect room}"
    channel = ServiceHelpers.get_by!(Channel, :name, room)
    broadcast! socket, "user:entered", %{user: msg["user"], channel_id: channel.id}
    push socket, "join", %{status: "connected"}
    # socket = Phoenix.Socket.assign(socket, :user_id, msg["user_id"])
    {:noreply, socket}
  end

  ##########
  # Outgoing message handlers

  def handle_out(ev = "lobby:" <> event, msg, socket) do
    debug ev, msg
    client_id = socket.assigns[:user_id]
    channel_id = msg[:channel_id]

    if Repo.one(from s in Subscription, where: s.client_id == ^client_id and s.channel_id == ^channel_id) do
      UcxChat.Endpoint.broadcast CC.chan_room <> "lobby", event, msg
    end

    # push socket, event, msg
    {:noreply, socket}
  end

  ##########
  # Incoming message handlers

  def handle_in(pattern, %{"params" => params, "ucxchat" =>  ucxchat} = msg, socket) do
    debug pattern, msg
    # Logger.debug "new handle_in params: #{inspect params}, ucxchat: #{inspect ucxchat}"
    UcxChat.ChannelRouter.route(socket, pattern, params, ucxchat)
  end

  def handle_in(ev = "flex_bar:click:" <> mod, msg, socket) do
    debug ev, msg
    resp = UcxChat.FlexBarService.handle_click(mod, msg)
    {:reply, resp, socket}
  end

  def handle_in(ev = "flex_bar:" <> mod, msg, socket) do
    debug ev, msg
    # Logger.debug "flex-bar mod: #{inspect mod}, msg: #{inspect msg}"
    resp = UcxChat.FlexBarService.handle_in(mod, msg)
    {:reply, resp, socket}
  end

  def handle_in(ev = "message_popup:" <> cmd, msg, socket) do
    debug ev, msg
    resp = UcxChat.MessagePopupService.handle_in(cmd, msg)
    {:reply, resp, socket}
  end

  def handle_in(ev = "message_cog:" <> cmd, msg, socket) do
    debug ev, msg
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
  def handle_in(event, msg, socket) do
    Logger.warn "RoomChannel no handler for: event: #{event}, msg: #{inspect msg}"
    {:noreply, socket}
  end


  #########
  # Private

end
