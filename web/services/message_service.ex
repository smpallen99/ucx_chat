defmodule UcxChat.MessageService do
  import Ecto.Query
  alias UcxChat.{Message, Repo, TypingAgent, Client, Mention}
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
    {body, mentions} = encode_mentions(message)
    message =
      %Message{}
      |> Message.changeset(%{
        sequential: client_id == last_client_id(channel_id),
        channel_id: channel_id,
        client_id: client_id,
        body: body
      })
      |> Repo.insert!
      |> Repo.preload([:client])

    create_mentions(mentions, message.id, message.channel_id)

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

  def encode_mentions(body) do
    re = ~r/(^|\s|\.|\!|:|,|\?)@([a-zA-Z0-9_-]*)/
    if (list = Regex.scan(re, body)) != [] do
      Enum.reduce(list, {body, []}, fn [_, _, name], {body, acc} ->
        encode_mention(name, body, acc)
      end)
    else
      {body, []}
    end
  end

  def encode_mention(name, body, acc) do
    Client
    |> where([c], c.nickname == ^name)
    |> Repo.one
    |> do_encode_mention(name, body, acc)
  end

  def do_encode_mention(nil, _, body, acc), do: {body, acc}
  def do_encode_mention(client, name, body, acc) do
    name_link = " <a class='mention-link' data-username='#{client.nickname}'>@#{client.nickname}</a> "
    body = String.replace body, ~r/(^|\s|\.|\!|:|,|\?)@#{name}[\.\!\?\,\:\s]*/, name_link
    {body, [client.id|acc]}
  end

  def create_mentions([], _, _), do: :ok
  def create_mentions([mention|mentions], message_id, channel_id) do
    create_mention(mention, message_id, channel_id)
    create_mentions(mentions, message_id, channel_id)
  end

  def create_mention(mention, message_id, channel_id) do
    %Mention{}
    |> Mention.changeset(%{client_id: mention, message_id: message_id, channel_id: channel_id})
    |> Repo.insert!
    |> notify_mention
  end

  defp notify_mention(_mention) do
    # have to figure out if we need to have another socket for this?
  end
end
