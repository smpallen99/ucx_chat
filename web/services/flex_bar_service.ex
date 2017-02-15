defmodule UcxChat.FlexBarService do
  import Ecto.Query

  alias UcxChat.{Repo, FlexBarView, Channel, Client}
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger

  def handle_in("Info", %{"channel_id" => channel_id} = msg)  do

    channel = Helpers.get_channel(channel_id)

    html = FlexBarView.render(msg["templ"], channel: channel)
    |> Phoenix.HTML.safe_to_string
    {:ok, %{html: html}}
  end
  def handle_in("Members List", %{"channel_id" => channel_id} = msg)  do
    channel = Helpers.get_channel(channel_id, [:clients])

    client = case msg["nickname"] do
      nil -> Helpers.get(Client, msg["client_id"])
      nickname -> Helpers.get_by(Client, :nickname, nickname)
    end
    # Logger.warn "FlexBarService client: #{inspect client}, msg: #{inspect msg}"

    html = FlexBarView.render(msg["templ"], clients: channel.clients, client: client)
    |> Phoenix.HTML.safe_to_string
    {:ok, %{html: html}}
  end
end
