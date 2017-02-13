defmodule UcxChat.MessageService do
  import Ecto.Query
  alias UcxChat.{Message, Repo, TypingAgent}

  require Logger

  def get_messages(channel_id) do
    Message
    |> where([m], m.channel_id == ^channel_id)
    |> preload([:client])
    # |> join(:left, [m], c in assoc(m, :client))
    # |> select([m,c], {m, c})
    # |> select([m,c], {m.id, m.body, m.updated_at, c.id, c.nickname})
    |> Repo.all
    # |> Enum.map(fn {m, c} ->
    #   struct(m, client: c)
    # end)
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
