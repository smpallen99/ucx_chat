defmodule UcxChat.MessagePopupService do
  require Logger
  alias UcxChat.{Repo, Client, Channel, Message}
  alias UcxChat.ServiceHelpers, as: Helpers
  import Ecto.Query

  def handle_in("get:users" <> _mod, msg) do
    Logger.debug "get:users, msg: #{inspect msg}"
    pattern = msg["pattern"] |> to_string
    clients = get_clients_by_pattern(msg["channel_id"], msg["client_id"], "%" <> pattern <> "%")

    if length(clients) > 0 do
      data = clients ++ [
        %{system: true, nickname: "all", name: "Notify all in this room", id: "all"},
        %{system: true, nickname: "here", name: "Notify active users in this room", id: "here"}
      ]
      chatd = %{open: true, title: "People", data: data, templ: "popup_user.html"}

      html =
        "popup.html"
        |> UcxChat.MessageView.render(chatd: chatd)
        |> Phoenix.HTML.safe_to_string

      {:ok, %{html: html}}
    else
      {:ok, %{close: true}}
    end
  end

  def get_clients_by_pattern(channel_id, client_id, pattern) do
    channel_clients = get_default_clients(channel_id, client_id, pattern)
    case length channel_clients do
      max when max >= 5 -> channel_clients
      size ->
        exclude = [client_id|Enum.map(channel_clients, &(&1[:id]))]
        channel_clients ++ get_all_clients(pattern, exclude, 5 - size)
    end
  end

  def get_all_clients(pattern, exclude, count) do
    Client
    |> where([c], like(c.nickname, ^pattern) and not c.id in ^exclude)
    |> order_by([c], asc: c.nickname)
    |> limit(^count)
    |> select([c], {c.id, c.nickname})
    |> Repo.all
    |> Enum.map(fn {id, nn} -> %{id: id, nickname: nn, status: "online"} end)
  end

  def get_default_clients(channel_id, client_id, pattern \\ "%") do
    client_ids =
      Message
      |> where([m], m.channel_id == ^channel_id and m.client_id != ^client_id)
      |> group_by([m], m.client_id)
      |> select([m], m.client_id)
      |> Repo.all
      |> Enum.reverse

    Client
    |> where([c], like(c.nickname, ^pattern) and c.id in ^client_ids)
    |> select([c], {c.id, c.nickname})
    |> Repo.all
    |> Enum.reverse
    |> Enum.take(5)
    |> Enum.map(fn {id, nn} -> %{nickname: nn, id: id, status: "online"} end)
  end
end
