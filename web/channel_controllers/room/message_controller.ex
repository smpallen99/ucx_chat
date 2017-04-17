defmodule UcxChat.MessageChannelController do
  use UcxChat.Web, :channel_controller

  import UcxChat.MessageService

  alias UcxChat.{
    User, Message, ChannelService, Channel, MessageService, Attachment,
    AttachmentService, Permission
  }
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger

  def create(%{assigns: assigns} = socket, params) do
    # Logger.warn "++++ socket: #{inspect socket}"
    message = params["message"]
    user_id = assigns[:user_id]
    user = Helpers.get_user user_id
    channel_id = assigns[:channel_id]

    channel = Helpers.get!(Channel, channel_id)
    msg_params = if Channel.direct?(channel), do: %{type: "d"}, else: %{}

    cond do
      ChannelService.user_muted? user_id, channel_id ->
        sys_msg = create_system_message(channel_id, ~g"You have been muted and cannot speak in this room")
        html = render_message(sys_msg)
        push_message(socket, sys_msg.id, user_id, html)

        msg = create_message(message, user_id, channel_id, %{ type: "p", })
        html = render_message(msg)
        push_message(socket, msg.id, user_id, html)

      channel.read_only and not Permission.has_permission?(user, "post-readonly", assigns.channel_id) ->
        push_error socket, ~g(You are not authorized to create a message)

      channel.archived ->
        push_error socket, ~g(You are not authorized to create a message)

      true ->
        {body, mentions} = encode_mentions(message, channel_id)
        UcxChat.RobotService.new_message body, channel, user

        message = create_message(body, user_id, channel_id, msg_params)
        create_mentions(mentions, message.id, message.channel_id, body)
        update_direct_notices(channel, message)
        message_html = render_message(message)
        broadcast_message(socket, message.id, message.user.id, message_html, body: body)
    end
    stop_typing(socket, user_id, channel_id)
    {:noreply, socket}
  end

  def index(%{assigns: assigns} = socket, params) do
    user = Helpers.get(User, assigns[:user_id])

    channel_id = assigns[:channel_id]
    timestamp = params["timestamp"]

    page_size = Application.get_env :ucx_chat, :page_size, 30
    preloads = MessageService.preloads()

    list =
      Message
      |> where([m], m.timestamp < ^timestamp and m.channel_id == ^channel_id)
      |> Helpers.last_page(page_size)
      |> preload(^preloads)
      |> Repo.all

    previews = MessageService.message_previews(user.id, list)

    messages_html =
      list
      |> Enum.map(fn message ->
        previews = List.keyfind(previews, message.id, 0, {nil, []}) |> elem(1)
        UcxChat.MessageView.render("message.html", user: user, message: message, previews: previews)
        |> Helpers.safe_to_string
      end)
      |> to_string

    messages_html = String.replace(messages_html, "\n", "")

    {:reply, {:ok, MessageService.messages_info_into(list, channel_id, user, %{html: messages_html})}, socket}
  end

  def previous(%{assigns: assigns} = socket, params) do
    user = Helpers.get(User, assigns[:user_id])

    channel_id = assigns[:channel_id]
    timestamp = params["timestamp"]

    page_size = Application.get_env :ucx_chat, :page_size, 75
    preloads = MessageService.preloads()
    list =
      Message
      |> where([m], m.timestamp > ^timestamp and m.channel_id == ^channel_id)
      |> limit(^page_size)
      |> preload(^preloads)
      |> Repo.all

    previews = MessageService.message_previews(user.id, list)

    messages_html =
      list
      |> Enum.map(fn message ->
        previews = List.keyfind(previews, message.id, 0, {nil, []}) |> elem(1)
        UcxChat.MessageView.render("message.html", user: user, message: message, previews: previews)
        |> Helpers.safe_to_string
      end)
      |> to_string

    messages_html = String.replace(messages_html, "\n", "")

    {:reply, {:ok, MessageService.messages_info_into(list, channel_id, user, %{html: messages_html})}, socket}
  end

  def surrounding(%{assigns: assigns} = socket, params) do
    user = Helpers.get(User, assigns[:user_id])
    channel_id = assigns[:channel_id]
    timestamp = params["timestamp"]

    list = MessageService.get_surrounding_messages(channel_id, timestamp, user)

    previews = MessageService.message_previews(user.id, list)

    messages_html =
      list
      |> Enum.map(fn message ->
        previews = List.keyfind(previews, message.id, 0, {nil, []}) |> elem(1)
        UcxChat.MessageView.render("message.html", user: user, message: message, previews: previews)
        |> Helpers.safe_to_string
      end)
      |> to_string

    messages_html = String.replace(messages_html, "\n", "")

    {:reply, {:ok, MessageService.messages_info_into(list, channel_id, user, %{html: messages_html})}, socket}
  end

  def last(%{assigns: assigns} = socket, _params) do
    user = Helpers.get(User, assigns[:user_id])
    channel_id = assigns[:channel_id]

    list = MessageService.get_messages(channel_id, user)

    previews = MessageService.message_previews(user.id, list)

    messages_html =
      list
      |> Enum.map(fn message ->
        UcxChat.MessageView.render("message.html", user: user, message: message, previews: previews)
        |> Helpers.safe_to_string
      end)
      |> to_string

    messages_html = String.replace(messages_html, "\n", "")

    {:reply, {:ok, MessageService.messages_info_into(list, channel_id, user, %{html: messages_html})}, socket}
  end

  def update(%{assigns: assigns} = socket, params) do
    user = Helpers.get(User, assigns[:user_id])
    channel_id = assigns[:channel_id]
    id = params["id"]

    value = params["message"]
    message = Helpers.get(Message, id, preload: [:attachments])
    resp =
      case message.attachments do
        [] -> update_message_body(message, value, user)
        [att|_] -> update_attachment_description(att, message, value, user)
      end
      |> case do
        {:ok, message} ->
          message = Repo.preload(message, MessageService.preloads())
          MessageService.broadcast_updated_message message
          {:ok, %{}}
        _error ->
          {:error, %{error: ~g(Problem updating your message)}}
      end

    stop_typing(socket, user.id, channel_id)
    {:reply, resp, socket}
  end

  def delete(%{assigns: assigns} = socket, params) do
    user = Helpers.get_user assigns.user_id
    if user.id == params["message_id"] || Permission.has_permission?(user, "delete-message", assigns.channel_id) do
      message = Helpers.get Message, params["message_id"], preload: [:attachments]
      case MessageService.delete_message message do
        {:ok, _} ->
          Phoenix.Channel.broadcast! socket, "code:update", %{selector: "li.message#" <> params["message_id"], action: "remove"}
        _ ->
          Phoenix.Channel.push socket, "toastr:error", %{error: ~g(There was an error deleting that message)}
      end
    else
      push_error socket, ~g(You are not authorized to delete that message)
    end
    {nil, %{}}
  end

  defp push_error(socket, error) do
    Phoenix.Channel.push socket, "toastr:error", %{error: error}
  end

  defp update_attachment_description(attachment, message, value, user) do
    Repo.transaction(fn ->
      message
      |> Message.changeset(%{edited_id: user.id})
      |> Repo.update
      |> case do
        {:ok, message} ->
          attachment
          |> Attachment.changeset(%{description: value})
          |> Repo.update
          |> case do
            {:ok, _attachment} ->
              {:ok, message}
            error ->
              Repo.rollback(:attachment_error)
              error
          end
        error -> error
      end
    end)
    |> case do
      {:ok, res} -> res
      {:error, _} -> {:error, nil}
    end
  end

  defp update_message_body(message, value, user) do
    message
    |> Message.changeset(%{body: value, edited_id: user.id})
    |> Repo.update
  end

  def delete_attachment(%{assigns: assigns} = socket, params) do
    user = Helpers.get(User, assigns[:user_id])
    attachment = Helpers.get Attachment, params["id"], preload: [:message]
    message = attachment.message
    if user.id == message.user_id || Permission.has_permission?(user, "delete-message", assigns.channel_id) do

      case AttachmentService.delete_attachment(attachment) do
        {:error, _} ->
          push_error socket, ~g(There was a problem deleting that file)
        _ -> nil
      end
      message = Repo.preload(message, [:attachments])
      if length(message.attachments) == 0 do
        Repo.delete message
        Phoenix.Channel.broadcast! socket, "code:update", %{selector: "li.message#" <> attachment.message.id, action: "remove"}
      else
        # broadcast edited message update
      end
      Phoenix.Channel.broadcast! socket, "code:update", %{selector: "li[data-id='" <> attachment.id <> "']", action: "remove"}
    else
      push_error socket, ~g(You are not authorized to delete that attachment)
    end
    {:reply, {:ok, %{}}, socket}
  end

end
