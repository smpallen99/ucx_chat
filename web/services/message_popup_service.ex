defmodule UcxChat.MessagePopupService do
  require Logger
  alias UcxChat.{Repo, Client, Channel}
  alias UcxChat.ServiceHelpers, as: Helpers

  def handle_in("open:" <> mod, msg) do
    Logger.warn "MessagePopupService.handle_in open:#{mod}, #{inspect msg}"
    clients =
      Channel
      |> Helpers.get(msg["channel_id"], preload: [:clients])
      |> Map.get(:clients)
      |> Enum.map(fn client ->
        %{nickname: client.nickname, id: client.id, status: "online"}
      end)
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
  end
end
