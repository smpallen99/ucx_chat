defmodule UcxChat.MessageService do
  import Ecto.Query
  alias UcxChat.{Message, Repo, TypingAgent, Client, Mention, Subscription}
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger

  # def broadcast_message(id, channel_id, client_id, html) do
  #   channel = Helpers.get
  # end
  def broadcast_message(id, room, client_id, html) when is_binary(room) do
    UcxChat.Endpoint.broadcast! "ucxchat:room-" <> room, "message:new", create_broadcast_message(id, client_id, html)
  end

  def broadcast_message(socket, id, client_id, html) do
    Phoenix.Channel.broadcast! socket, "message:new", create_broadcast_message(id, client_id, html)
  end

  defp create_broadcast_message(id, client_id, html) do
    %{
      html: html,
      id: "message-#{id}",
      client_id: client_id
    }
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

  def render_message(message) do
    "message.html"
    |> UcxChat.MessageView.render(message: message, client: message.client)
    |> Phoenix.HTML.safe_to_string
  end

  def create_message(body, client_id, channel_id, params) do
    # Logger.warn "create_msg body: #{inspect body}, params: #{inspect params}"
    message =
      %Message{}
      |> Message.changeset(Map.merge(
        %{
          sequential: client_id == last_client_id(channel_id),
          channel_id: channel_id,
          client_id: client_id,
          body: body
        }, params))
      |> Repo.insert!
      |> Repo.preload([:client])
    if params[:type] == "p" do
      Repo.delete(message)
    end
    message
  end

  def create_message(body, client_id, channel_id) do
    %Message{}
    |> Message.changeset(%{
      sequential: client_id == last_client_id(channel_id),
      channel_id: channel_id,
      client_id: client_id,
      body: body
    })
    |> Repo.insert!
    |> Repo.preload([:client])
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

    subs =
      Subscription
      |> where([s], s.client_id == ^mention and s.channel_id == ^channel_id)
      |> Repo.one!

    subs
    |> Subscription.changeset(%{unread: subs.unread + 1})
    |> Repo.update!
  end

  def create_and_render(body, client_id, channel_id, opts \\ []) do
    message = create_message(body, client_id, channel_id, Enum.into(opts, %{}))
    Logger.warn "create_and_render message: #{inspect message}"
    {message, render_message(message)}
  end

  defp notify_mention(_mention) do
    # have to figure out if we need to have another socket for this?
  end
end
