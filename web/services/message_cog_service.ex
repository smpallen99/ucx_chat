defmodule UcxChat.MessageCogService do
  require Logger
  alias UcxChat.{
    Repo, Message, MessageView, StaredMessage, PinnedMessage, FlexBarView
  }
  alias UcxChat.ServiceHelpers, as: Helpers
  import Ecto.Query

  def handle_in("open", %{"flex_tab" => true}, _) do
    html = FlexBarView.render("flex_cog.html")
    |> Helpers.safe_to_string
    {nil, %{html: html}}
  end

  def handle_in("open", %{"user_id" => user_id, "channel_id" => channel_id} = msg, _) do
    id = get_message_id msg["message_id"]
    star_count =
      StaredMessage
      |> where([s], s.user_id == ^user_id and s.message_id == ^id and s.channel_id == ^channel_id)
      |> select([s], count(s.id))
      |> Repo.one
    pin_count =
      PinnedMessage
      |> where([s], s.message_id == ^id)
      |> select([s], count(s.id))
      |> Repo.one
    opts = [stared: star_count > 0, pinned: pin_count > 0]
    Logger.warn "MessageCogService: open, msg: #{inspect msg}, id: #{inspect id}"
    html = MessageView.render("message_cog.html", opts: opts)
    |> Helpers.safe_to_string

    {nil, %{html: html}}
  end

  def handle_in("star-message", %{"user_id" => user_id, "channel_id" => channel_id} = msg, _) do
    id = get_message_id msg["message_id"]
    star =
      %StaredMessage{}
      |> StaredMessage.changeset(%{message_id: id, user_id: user_id, channel_id: channel_id})
      |> Repo.insert!
    Logger.warn "star: #{inspect star}"
    {"update:stared", %{}}
  end

  def handle_in("unstar-message", %{"user_id" => user_id, "channel_id" => channel_id} = msg, _) do
    id = get_message_id msg["message_id"]
    StaredMessage
    |> where([s], s.user_id == ^user_id and s.message_id == ^id and s.channel_id == ^channel_id)
    |> Repo.one!
    |> Repo.delete!
    {"update:stared", %{}}
  end

  def handle_in("pin-message", %{"user_id" => _user_id, "channel_id" => channel_id} = msg, _) do
    id = get_message_id msg["message_id"]
    message = Repo.get Message, id
    pin =
      %PinnedMessage{}
      |> PinnedMessage.changeset(%{message_id: id, user_id: message.user_id, channel_id: channel_id})
      |> Repo.insert!
    Logger.warn "pin: #{inspect pin}"
    {"update:pinned", %{}}
  end

  def handle_in("unpin-message", %{"user_id" => _user_id, "channel_id" => _channel_id} = msg, _) do
    id = get_message_id msg["message_id"]
    PinnedMessage
    |> where([s], s.message_id == ^id)
    |> Repo.one!
    |> Repo.delete!
    {"update:pinned", %{}}
  end
  # def handle_in("edit-message", %{"user_id" => _user_id, "channel_id" => _channel_id}, _socket) do

  # end
  def handle_in("delete-message", %{"user_id" => _user_id, "channel_id" => _channel_id} = msg, socket) do
    message = Helpers.get Message, get_message_id(msg["message_id"])
    Repo.delete message
    Phoenix.Channel.broadcast! socket, "code:update", %{selector: "li.message#" <> msg["message_id"], action: "remove"}
    {nil, %{}}
  end

  # def handle_in("jump-to-message", msg, _) do
  #   {nil, %{}}
  # end

  defp get_message_id(id), do: id
end
