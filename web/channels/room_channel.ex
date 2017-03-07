defmodule UcxChat.RoomChannel do
  @moduledoc """
  Handle incoming and outgoing Subscription messages
  """
  use Phoenix.Channel
  use UcxChat.ChannelApi

  import Ecto.Query

  alias UcxChat.{Subscription, Repo, Channel, Message}
  alias UcxChat.{ServiceHelpers, Permission, UserSocket}
  alias UcxChat.ServiceHelpers, as: Helpers

  require UcxChat.ChatConstants, as: CC
  require Logger

  ############
  # API
  # intercept ["lobby:room:update:name"]
  intercept ["user:action", "room:state_change"]

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

  def handle_out(ev = "room:state_change", msg, %{assigns: assigns} = socket) do
    warn ev, msg, "assigns: #{inspect assigns}"
    channel_id = assigns[:channel_id] || msg[:channel_id]
    if channel_id do
      UserSocket.push_message_box(socket, channel_id, assigns.user_id)
    end

    {:noreply, socket}
  end

  def handle_out(ev = "user:action", msg, socket) do
    warn ev, msg
    {:noreply, socket}
  end
  def handle_out(ev = "lobby:" <> event, msg, socket) do
    debug ev, msg
    user_id = socket.assigns[:user_id]
    channel_id = msg[:channel_id]

    if Repo.one(from s in Subscription, where: s.user_id == ^user_id and s.channel_id == ^channel_id) do
      UcxChat.Endpoint.broadcast CC.chan_room <> "lobby", event, msg
    end

    # push socket, event, msg
    {:noreply, socket}
  end

  ##########
  # Incoming message handlers

  def handle_in(pattern, %{"params" => params, "ucxchat" =>  ucxchat} = msg, socket) do
    debug pattern, msg
    user = Helpers.get_user! socket.assigns.user_id
    if authorized? socket, String.split(pattern, "/"), params, ucxchat, user do
      UcxChat.ChannelRouter.route(socket, pattern, params, ucxchat)
    else
      push socket, "toastr:error", %{message: "You are not authorized!"}
      {:noreply, socket}
    end
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
    resp = case UcxChat.MessageCogService.handle_in(cmd, msg, socket) do
      {:nil, msg} ->
        {:ok, msg}
      {event, msg} ->
        Logger.warn "msg cog ret event: #{inspect event}, msg: #{inspect msg}"
        broadcast! socket, event, %{}
        {:ok, msg}
    end
    {:reply, resp, socket}
  end
  def handle_in(ev = "message:get-body:message-" <> id, msg, socket) do
    debug ev, msg
    message = Helpers.get Message, String.to_integer(id)
    {:reply, {:ok, %{body: message.body}}, socket}
  end
  # default case
  def handle_in(event, msg, socket) do
    Logger.warn "RoomChannel no handler for: event: #{event}, msg: #{inspect msg}"
    {:noreply, socket}
  end


  #########
  # Private

  @room_commands ~w(set-owner set-moderator mute-user remove-user)

  defp authorized?(_socket, ["room_settings" | _], _params, ucxchat, user) do
    # Logger.warn "authorized? pattern: #{inspect pattern}, params: #{inspect params}, ucxchat: #{inspect ucxchat}"
    Permission.has_permission? user, "edit-room", ucxchat["assigns"]["channel_id"]
  end
  defp authorized?(_socket, pattern = ["room", command, username], _params, ucxchat, user) when command in @room_commands do
    Permission.has_permission? user, command, ucxchat["assigns"]["channel_id"]
  end

  defp authorized?(_socket, _pattern, _params, _ucxchat, _), do: true
end
