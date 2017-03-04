defmodule UcxChat.RoomChannelController do
  use UcxChat.Web, :channel_controller

  alias UcxChat.{ChannelService, User}
  alias UcxChat.ServiceHelpers, as: Helpers
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

  # def command(socket, %{"command" => "set-owner", "username" => username}) do
  #   Logger.warn "RoomChannelController: command: set-owner, username: #{inspect username}"

  #   {:noreply, socket}
  # end

  # def command(socket, %{"command" => "mute-user", "username" => username}) do
  #   Logger.warn "RoomChannelController: command: mute-user, username: #{inspect username}, socket: #{inspect socket}"
  #   user = Helpers.get_by! User, :username, username

  #   resp = case ChannelService.user_command(socket, :mute, user, socket.assigns.user_id, socket.assigns.channel_id) do
  #     {:ok, msg} ->
  #       # push socket, "toastr:success", %{message: }
  #       {:ok, %{}}
  #     {:error, error} ->
  #       {:error, %{error: error}}
  #   end
  #   {:reply, resp, socket}
  # end
  @commands ~w(mute-user unmute-user set-moderator unset-moderator set-owner unset-owner remove-user)
  @command_list Enum.zip(@commands, ~w(mute unmute set_moderator unset_moderator set_owner unset_owner remove_user)a) |> Enum.into(%{})
  @messages [
    nil,
    "User unmuted in Room",
    "User %%user%% is now a moderator of %%room%%",
    "User %%user%% remove from %%room%% moderators",
    "User %%user%% is now an owner of %%room%%",
    "User %%user%% removed from %%room%% owners",
    nil
  ]
  @message_list Enum.zip(@commands, @messages) |> Enum.into(%{})

  def command(socket, %{"command" => command, "username" => username}) when command in @commands do
    Logger.warn "RoomChannelController: command: #{command}, username: #{inspect username}, socket: #{inspect socket}"
    user = Helpers.get_by! User, :username, username

    # resp = case ChannelService.user_command(:unmute, user, socket.assigns.user_id, socket.assigns.channel_id) do
    resp = case ChannelService.user_command(socket, @command_list[command], user, socket.assigns.user_id, socket.assigns.channel_id) do
      {:ok, msg} ->
        if message = @message_list[command] do
          message = message |> String.replace("%%user%%", user.username) |> String.replace("%%room%%", socket.assigns.room)
          Phoenix.Channel.push socket, "toastr:success", %{message: message}
        end
        {:ok, %{}}
      {:error, error} ->
        {:error, %{error: error}}
    end
    {:reply, resp, socket}
  end

  def command(socket, %{"command" => command, "username" => username}) do
    Logger.warn "RoomChannelController: command: #{inspect command}, username: #{inspect username}"
    {:reply, {:ok, %{}}, socket}
  end
end
