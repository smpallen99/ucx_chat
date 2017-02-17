defmodule UcxChat.MessageService do
  import Ecto.Query
  alias UcxChat.{Message, Repo, TypingAgent, Client}
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger

  def handle_in("load", msg) do
    client = Helpers.get(Client, msg["client_id"])
    Logger.warn "MessageService.handle_in load msg: #{inspect msg}, client: #{inspect client}"
    channel_id = msg["channel_id"]
    timestamp = msg["timestamp"]
    Logger.warn "timestamp: #{inspect timestamp}"
    page_size = Application.get_env :ucx_chat, :page_size, 150
    messages =
      Message
      |> where([m], m.timestamp < ^timestamp and m.channel_id == ^channel_id)
      |> Helpers.last_page(page_size)
      |> preload([:client])
      |> Repo.all
      |> Enum.map(fn message ->
        UcxChat.MessageView.render("message.html", client: client, message: message)
        |> Phoenix.HTML.safe_to_string
      end)
      |> to_string
    {:ok, %{html: messages}}
  end

  def get_messages(channel_id) do
    Message
    |> where([m], m.channel_id == ^channel_id)
    |> Helpers.last_page
    |> preload([:client])
    |> Repo.all
  end

  def last_client_id(channel_id) do
    Message
    |> where([m], m.channel_id == ^channel_id)
    |> last
    |> Repo.one
    |> case do
      nil -> nil
      message -> Map.get(message, :client_id)
    end
  end

  def new_message(channel_id, message, client_id, room) do
    message =
      %Message{}
      |> Message.changeset(%{
        sequential: client_id == last_client_id(channel_id),
        channel_id: channel_id,
        client_id: client_id,
        body: message
      })
      |> Repo.insert!
      |> Repo.preload([:client])

    message_html =
      "message.html"
      |> UcxChat.MessageView.render(message: message, client: message.client)
      |> Phoenix.HTML.safe_to_string

    UcxChat.Endpoint.broadcast("ucxchat:room-" <> room, "message:new",
      %{
        html: message_html,
        id: "message-#{message.id}",
        client_id: message.client_id
      })
    TypingAgent.stop_typing(channel_id, client_id)
    update_typing(channel_id, room)
  end

  def update_typing(channel_id, room) do
    typing = TypingAgent.get_typing_names(channel_id)
    UcxChat.Endpoint.broadcast("ucxchat:room-" <> room, "typing:update", %{typing: typing})
  end
end
