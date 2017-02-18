defmodule UcxChat.MessageCogService do
  require Logger
  alias UcxChat.{Repo, Client, Channel, Message, MessageView, StaredMessage, PinnedMessage}
  alias UcxChat.ServiceHelpers, as: Helpers
  import Ecto.Query

  def handle_in("open", %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    "message-" <> id = msg["message_id"]
    id = String.to_integer(id)
    star_count =
      StaredMessage
      |> where([s], s.client_id == ^client_id and s.message_id == ^id and s.channel_id == ^channel_id)
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
    |> Phoenix.HTML.safe_to_string

    {nil, %{html: html}}
  end

  def handle_in("star-message", %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    "message-" <> id = msg["message_id"]
    id = String.to_integer(id)
    star =
      %StaredMessage{}
      |> StaredMessage.changeset(%{message_id: id, client_id: client_id, channel_id: channel_id})
      |> Repo.insert!
    Logger.warn "star: #{inspect star}"
    {"update:stared", %{}}
  end

  def handle_in("unstar-message", %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    "message-" <> id = msg["message_id"]
    id = String.to_integer(id)
    StaredMessage
    |> where([s], s.client_id == ^client_id and s.message_id == ^id and s.channel_id == ^channel_id)
    |> Repo.one!
    |> Repo.delete!
    {"update:stared", %{}}
  end

  def handle_in("pin-message", %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    "message-" <> id = msg["message_id"]
    id = String.to_integer(id)
    message = Repo.get Message, id
    pin =
      %PinnedMessage{}
      |> PinnedMessage.changeset(%{message_id: id, client_id: message.client_id, channel_id: channel_id})
      |> Repo.insert!
    Logger.warn "pin: #{inspect pin}"
    {"update:pinned", %{}}
  end

  def handle_in("unpin-message", %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    "message-" <> id = msg["message_id"]
    id = String.to_integer(id)
    PinnedMessage
    |> where([s], s.message_id == ^id)
    |> Repo.one!
    |> Repo.delete!
    {"update:pinned", %{}}
  end
end
