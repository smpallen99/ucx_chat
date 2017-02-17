defmodule UcxChat.MessageCogService do
  require Logger
  alias UcxChat.{Repo, Client, Channel, Message, MessageView, StaredMessage}
  alias UcxChat.ServiceHelpers, as: Helpers
  import Ecto.Query

  def handle_in("open", %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    "message-" <> id = msg["message_id"]
    id = String.to_integer(id)
    count =
      StaredMessage
      |> where([s], s.client_id == ^client_id and s.message_id == ^id and s.channel_id == ^channel_id)
      |> select([s], count(s.id))
      |> Repo.one
    opts = [stared: count > 0]
    Logger.warn "MessageCogService: open, msg: #{inspect msg}, id: #{inspect id}"
    html = MessageView.render("message_cog.html", opts: opts)
    |> Phoenix.HTML.safe_to_string

    {:ok, %{html: html}}
  end

  def handle_in("star-message", %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    "message-" <> id = msg["message_id"]
    id = String.to_integer(id)
    star =
      %StaredMessage{}
      |> StaredMessage.changeset(%{message_id: id, client_id: client_id, channel_id: channel_id})
      |> Repo.insert!
    Logger.warn "star: #{inspect star}"
    {:ok, %{}}
  end

  def handle_in("unstar-message", %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    "message-" <> id = msg["message_id"]
    id = String.to_integer(id)
    StaredMessage
    |> where([s], s.client_id == ^client_id and s.message_id == ^id and s.channel_id == ^channel_id)
    |> Repo.one!
    |> Repo.delete!
    {:ok, %{}}
  end
end
