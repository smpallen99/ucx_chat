defmodule UcxChat.MessageChannelController do
  use UcxChat.Web, :channel_controller

  alias UcxChat.{TypingAgent}
  alias UcxChat.ServiceHelpers, as: Helpers
  import UcxChat.MessageService
  # import Phoenix.Channel

  require Logger

  def create(%{assigns: assigns} = socket, params) do
    # Logger.warn "++++ socket: #{inspect socket}"
    message = params["message"]
    user_id = assigns[:user_id]
    channel_id = assigns[:channel_id]
    room = assigns[:room]

    {body, mentions} = encode_mentions(message)

    message = create_message(body, user_id, channel_id)
    create_mentions(mentions, message.id, message.channel_id)
    message_html = render_message(message)
    broadcast_message(socket, message.id, message.user.id, message_html)

    TypingAgent.stop_typing(channel_id, user_id)
    update_typing(channel_id, room)
    {:noreply, socket}
  end

  def index(%{assigns: assigns}, params) do
    user = Helpers.get(User, assigns[:user_id])
    # Logger.warn "MessageService.handle_in load msg: #{inspect msg}, user: #{inspect user}"
    channel_id = assigns[:channel_id]
    timestamp = params["timestamp"]
    # Logger.warn "timestamp: #{inspect timestamp}"
    page_size = Application.get_env :ucx_chat, :page_size, 150
    messages =
      Message
      |> where([m], m.timestamp < ^timestamp and m.channel_id == ^channel_id)
      |> Helpers.last_page(page_size)
      |> preload([:user])
      |> Repo.all
      |> Enum.map(fn message ->
        UcxChat.MessageView.render("message.html", user: user, message: message)
        |> Phoenix.HTML.safe_to_string
      end)
      |> to_string
    {:reply, {:ok, %{html: messages}}}
  end
end
