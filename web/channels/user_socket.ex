defmodule UcxChat.UserSocket do
  use Phoenix.Socket
  alias UcxChat.{User, Repo}
  require UcxChat.ChatConstants, as: CC

  require Logger

  ## Channels
  channel CC.chan_room <> "*", UcxChat.RoomChannel    # "ucxchat:"
  channel CC.chan_user <> "*", UcxChat.UserChannel  # "user:"
  channel CC.chan_system <> "*", UcxChat.SystemChannel  # "system:"

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the user and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  def connect(%{"token" => token, "tz_offset" => tz_offset}, socket) do
    # Logger.warn "socket connect params: #{inspect params}, socket: #{inspect socket}"
    case Coherence.verify_user_token(socket, token, &assign/3) do
      {:error, _} -> :error
      {:ok, %{assigns: %{user_id: user_id}} = socket} ->
        {user_id, username} = User.user_id_and_username(user_id) |> Repo.one
        # user_id = Repo.get!(User, user_id) |> Map.get(:user_id)
        {
          :ok,
          socket
          |> assign(:user_id, user_id)
          |> assign(:username, username)
          |> assign(:tz_offset, tz_offset)
        }
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     UcxChat.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket), do: "users_socket:#{socket.assigns.user_id}"
end
