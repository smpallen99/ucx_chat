defmodule UcxChat.FlexBarService do
  import Ecto.Query

  alias UcxChat.{Repo, FlexBarView, Channel}
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger

  def handle_in("Info", %{"channel_id" => channel_id} = msg)  do
    #{templ: "channel_settings.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})

    channel = Helpers.get_channel(channel_id)

    html = FlexBarView.render(msg["templ"], channel: channel)
    |> Phoenix.HTML.safe_to_string
    {:ok, %{html: html}}
  end
  def handle_in("Members List", %{"channel_id" => channel_id} = msg)  do
    #{templ: "channel_settings.html", client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
    channel = Helpers.get_channel(channel_id, [:clients])
    client = Helpers.get_client_by_name(msg["nickname"])
    Logger.warn "FlexBarService client: #{inspect client}"

    html = FlexBarView.render(msg["templ"], clients: channel.clients, client: client)
    |> Phoenix.HTML.safe_to_string
    {:ok, %{html: html}}
  end
end
