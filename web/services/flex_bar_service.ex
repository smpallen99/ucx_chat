defmodule UcxChat.FlexBarService do
  import Ecto.Query

  alias UcxChat.{Repo, FlexBarView, Channel, Client, User, Mention}
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

    {client, user_mode} = case msg["nickname"] do
      nil -> {Helpers.get(Client, msg["client_id"]), false}
      nickname -> {Helpers.get_by(Client, :nickname, nickname), true}
    end
    # Logger.warn "FlexBarService client: #{inspect client}, msg: #{inspect msg}"

    html = FlexBarView.render(msg["templ"], clients: channel.clients, client: client, user_mode: user_mode)
    |> Phoenix.HTML.safe_to_string
    {:ok, %{html: html}}
  end

  def handle_in("Switch User", msg) do
    Logger.debug "FlexBarService.handle_in Switch User: #{inspect msg}"
    users = Repo.all User

    html = FlexBarView.render(msg["templ"], users: users)
    |> Phoenix.HTML.safe_to_string
    {:ok, %{html: html}}
  end

  def handle_in("Mentions", %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    Logger.warn "FlexBarService.handle_in Mentions: #{inspect msg}"
    mentions =
      Mention
      |> where([m], m.client_id == ^client_id and m.channel_id == ^channel_id)
      |> preload([:client, :message])
      |> Repo.all
      |> Enum.reduce({nil, []}, fn m, {last_day, acc} ->
        day = NaiveDateTime.to_date(m.updated_at)
        msg =
          %{
            message: m.message,
            nickname: m.client.nickname,
            client: m.client,
            own: m.message.client_id == client_id,
            id: m.id,
            new_day: day != last_day,
            date: Helpers.format_date(m.message.updated_at),
            time: Helpers.format_time(m.message.updated_at),
            timestamp: m.message.timestamp
          }
        {day, [msg|acc]}
      end)
      |> elem(1)
      |> Enum.reverse

    html = FlexBarView.render(msg["templ"], mentions: mentions)
    |> Phoenix.HTML.safe_to_string
    {:ok, %{html: html}}
  end
end
