defmodule UcxChat.MessageService do
  import Ecto.Query
  alias UcxChat.{Message, Repo, TypingAgent, User, Mention, Subscription,
          Settings, MessageView, ChatDat, Channel}
  alias UcxChat.ServiceHelpers, as: Helpers
  require UcxChat.ChatConstants, as: CC

  require Logger

  # def broadcast_message(id, channel_id, user_id, html) do
  #   channel = Helpers.get
  # end
  def broadcast_message(id, room, user_id, html, event \\ "new")
  def broadcast_message(id, room, user_id, html, event) when is_binary(room) do
    UcxChat.Endpoint.broadcast! CC.chan_room <> room, "message:" <> event, create_broadcast_message(id, user_id, html)
  end

  def broadcast_message(socket, id, user_id, html, event) do
    Phoenix.Channel.broadcast! socket, "message:" <> event, create_broadcast_message(id, user_id, html)
  end

  def push_message(socket, id, user_id, html) do
    Phoenix.Channel.push socket, "message:new", create_broadcast_message(id, user_id, html)
  end


  defp create_broadcast_message(id, user_id, html) do
    %{
      html: html,
      id: "message-#{id}",
      user_id: user_id
    }
  end

  def get_messages(channel_id, %{tz_offset: tz}) do
    Logger.warn "get_messages ========================="
    Message
    |> where([m], m.channel_id == ^channel_id)
    |> Helpers.last_page
    |> preload([:user, :edited_by])
    |> Repo.all
    |> new_days(tz || 0, [])
  end

  defp new_days([h|t], tz, []), do: new_days(t, tz, [Map.put(h, :new_day, true)])
  defp new_days([h|t], tz, [last|_] = acc) do
    dt1 = Timex.shift(h.inserted_at, hours: tz)
    dt2 = Timex.shift(last.inserted_at, hours: tz)
    h = if Timex.day(dt1) == Timex.day(dt2) do
      h
    else
      Map.put(h, :new_day, true)
    end
    new_days t, tz, [h|acc]
  end
  defp new_days([], _, []), do: []
  defp new_days([], _, acc), do: Enum.reverse(acc)

  def last_user_id(channel_id) do
    channel_id
    |> last_message
    |> case do
      nil -> nil
      message -> Map.get(message, :user_id)
    end
  end

  def last_message(channel_id) do
    Message
    |> where([m], m.channel_id == ^channel_id)
    |> last
    |> Repo.one
  end

  def render_message(message) do
    user_id = message.user.id
    user = Repo.one(from u in User, where: u.id == ^user_id)
    "message.html"
    |> UcxChat.MessageView.render(message: message, user: user)
    |> Phoenix.HTML.safe_to_string
  end

  def create_system_message(channel_id, body) do
    bot_id = Helpers.get_bot_id()
    create_message(body, bot_id, channel_id,
      %{
        type: "p",
        system: true,
        sequential: false,
      })
  end

  def create_message(body, user_id, channel_id, params \\ %{}) do
    # Logger.warn "create_msg body: #{inspect body}, params: #{inspect params}"
    sequential? = case last_message(channel_id) do
      nil -> false
      lm ->
        Timex.after?(Timex.shift(lm.inserted_at,
          seconds: Settings.grouping_period_seconds()), Timex.now) and
          user_id == lm.user_id
    end

    message =
      %Message{}
      |> Message.changeset(Map.merge(
        %{
          sequential: sequential?,
          channel_id: channel_id,
          user_id: user_id,
          body: body
        }, params))
      |> Repo.insert!
      |> Repo.preload([:user])
    if params[:type] == "p" do
      Repo.delete(message)
    end
    message
  end

  def stop_typing(socket, user_id, channel_id) do
    TypingAgent.stop_typing(channel_id, user_id)
    update_typing(socket, channel_id)
  end

  def update_typing(%{} = socket, channel_id) do
    typing = TypingAgent.get_typing_names(channel_id)
    Phoenix.Channel.broadcast! socket, "typing:update", %{typing: typing}
  end

  def update_typing(channel_id, room) do
    typing = TypingAgent.get_typing_names(channel_id)
    UcxChat.Endpoint.broadcast(CC.chan_room <> room, "typing:update", %{typing: typing})
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
    User
    |> where([c], c.username == ^name)
    |> Repo.one
    |> do_encode_mention(name, body, acc)
  end

  def do_encode_mention(nil, _, body, acc), do: {body, acc}
  def do_encode_mention(user, name, body, acc) do
    name_link = " <a class='mention-link' data-username='#{user.username}'>@#{user.username}</a> "
    body = String.replace body, ~r/(^|\s|\.|\!|:|,|\?)@#{name}[\.\!\?\,\:\s]*/, name_link
    {body, [user.id|acc]}
  end

  def create_mentions([], _, _), do: :ok
  def create_mentions([mention|mentions], message_id, channel_id) do
    create_mention(mention, message_id, channel_id)
    create_mentions(mentions, message_id, channel_id)
  end

  def create_mention(mention, message_id, channel_id) do
    %Mention{}
    |> Mention.changeset(%{user_id: mention, message_id: message_id, channel_id: channel_id})
    |> Repo.insert!
    |> notify_mention

    subs =
      Subscription
      |> where([s], s.user_id == ^mention and s.channel_id == ^channel_id)
      |> Repo.one!

    subs
    |> Subscription.changeset(%{unread: subs.unread + 1})
    |> Repo.update!
  end

  def create_and_render(body, user_id, channel_id, opts \\ []) do
    message = create_message(body, user_id, channel_id, Enum.into(opts, %{}))
    {message, render_message(message)}
  end

  defp notify_mention(_mention) do
    # have to figure out if we need to have another socket for this?
  end

  def render_message_box(channel_id, user_id) do
    user = Helpers.get_user! user_id
    channel = Helpers.get!(Channel, channel_id)
    chatd = ChatDat.new(user, channel)
    MessageView.render("message_box.html", chatd: chatd, mb: MessageView.get_mb(chatd))
    |> Phoenix.HTML.safe_to_string
  end
end
