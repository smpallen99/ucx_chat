defmodule UcxChat.MessageChannelController do
  use UcxChat.Web, :channel_controller

  alias UcxChat.{TypingAgent, User, Message, ChannelService, Channel, MessageService}
  alias UcxChat.ServiceHelpers, as: Helpers
  import UcxChat.MessageService
  # import Phoenix.Channel

  require Logger

  def create(%{assigns: assigns} = socket, params) do
    Logger.warn "++++ socket: #{inspect socket}"
    message = params["message"]
    user_id = assigns[:user_id]
    channel_id = assigns[:channel_id]
    room = assigns[:room]
    channel = Helpers.get!(Channel, channel_id)
    msg_params = if Channel.direct?(channel), do: %{type: "d"}, else: %{}


    if ChannelService.user_muted? user_id, channel_id do
      sys_msg = create_system_message(channel_id, "You have been muted and cannot speak in this room")
      html = render_message(sys_msg)
      push_message(socket, sys_msg.id, user_id, html)

      msg = create_message(message, user_id, channel_id, %{ type: "p", })
      html = render_message(msg)
      push_message(socket, msg.id, user_id, html)
    else
      {body, mentions} = encode_mentions(message, channel_id)

      message = create_message(body, user_id, channel_id, msg_params)
      create_mentions(mentions, message.id, message.channel_id)
      message_html = render_message(message)
      broadcast_message(socket, message.id, message.user.id, message_html)
    end
    stop_typing(socket, user_id, channel_id)
    {:noreply, socket}
  end

  def index(%{assigns: assigns} = socket, params) do
    user = Helpers.get(User, assigns[:user_id])
    # Logger.warn "MessageService.handle_in load msg: #{inspect msg}, user: #{inspect user}"
    channel_id = assigns[:channel_id]
    timestamp = params["timestamp"]
    # Logger.warn "timestamp: #{inspect timestamp}"
    page_size = Application.get_env :ucx_chat, :page_size, 30
    list =
      Message
      |> where([m], m.timestamp < ^timestamp and m.channel_id == ^channel_id)
      |> Helpers.last_page(page_size)
      |> preload([:user, :edited_by])
      |> Repo.all
    Logger.warn "list size: #{inspect length list}"
    info = MessageService.get_messages_info list, channel_id
    messages_html =
      list
      |> Enum.map(fn message ->
        UcxChat.MessageView.render("message.html", user: user, message: message)
        |> Phoenix.HTML.safe_to_string
      end)
      |> to_string
    messages_html = String.replace(messages_html, "\n", "")
    # Logger.warn "html: #{messages_html}"
    {:reply, {:ok, %{html: messages_html, has_more: info.has_more}}, socket}
  end

  def update(%{assigns: assigns} = socket, params) do
    user = Helpers.get(User, assigns[:user_id])
    channel_id = assigns[:channel_id]
    "message-" <> id = params["id"]
    id = String.to_integer id

    value = params["message"]
    Helpers.get(Message, id)
    |> Message.changeset(%{body: value, edited_id: user.id})
    |> Repo.update
    |> case do
      {:ok, message} ->
        message = Repo.preload(message, [:user, :edited_by])
        # TODO: Need to handle new mentions for edited message
        message_html = render_message(message)
        broadcast_message(socket, message.id, message.user.id, message_html, "update")

        stop_typing(socket, user.id, channel_id)
    end

    Logger.warn "MessageController.update id: #{inspect id}, value: #{inspect value}"
    {:reply, {:ok, %{}}, socket}
  end
end
