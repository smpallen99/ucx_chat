defmodule UcxChat.ChannelController do
  use UcxChat.Web, :controller

  alias UcxChat.{Channel, User}

  import Ecto.Query

  require Logger
  require IEx

  alias UcxChat.Channel, as: Channel
  alias UcxChat.{MessageService, ChatDat, User}

  def index(conn, _params) do
    user = Coherence.current_user(conn)
    channel = if user.open_id do
      Repo.get!(Channel, user.open_id)
    else
      channel =
        UcxChat.Channel
        |> Ecto.Query.first
        |> Repo.one

      user
      |> User.changeset(%{open_id: channel.id})
      |> Repo.update!
      channel
    end

    show(conn, channel)
  end

  def show(conn, %Channel{} = channel) do
    user =
      conn
      |> Coherence.current_user
      |> Repo.preload([:account])

    UcxChat.PresenceAgent.load user.id

    messages = MessageService.get_messages(channel.id, user)
    chatd = ChatDat.new(user, channel, messages)

    conn
    |> put_view(UcxChat.MasterView)
    |> render("main.html", chatd: chatd)
  end

  def show(conn, %{"id" => id}) do
    channel =
      Channel
      |> where([c], c.name == ^id)
      |> Repo.one!
    show(conn, channel)
  end

end
