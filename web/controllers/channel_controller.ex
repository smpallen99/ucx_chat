defmodule UcxChat.ChannelController do
  use UcxChat.Web, :controller

  alias UcxChat.{Channel, User, Direct, ChannelService}

  import Ecto.Query

  require Logger
  require IEx

  alias UcxChat.Channel, as: Channel
  alias UcxChat.{MessageService, ChatDat, User}

  def index(conn, _params) do
    user = Coherence.current_user(conn)
    channel = if user.open_id do
      case Repo.get(Channel, user.open_id) do
        nil -> Repo.all(Channel) |> hd
        channel -> channel
      end
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

    messages = MessageService.get_room_messages(channel.id, user)
    # Logger.warn "message count #{length messages}"

    chatd =
      user
      |> ChatDat.new(channel, messages)
      |> ChatDat.get_messages_info

    # Logger.warn "controller messages_info: #{inspect chatd.messages_info}"
    conn
    |> put_view(UcxChat.MasterView)
    |> render("main.html", chatd: chatd)
  end

  def show(conn, %{"name" => name}) do
    channel =
      Channel
      |> where([c], c.name == ^name)
      |> Repo.one!
    show(conn, channel)
  end

  def direct(conn, %{"name" => name}) do
    case UcxChat.ServiceHelpers.get_by User, :username, name do
      nil ->
        redirect conn, to: "/"
      _ ->
        user_id = Coherence.current_user(conn) |> Map.get(:id)
        user_id
        |> get_direct(name)
        |> case do
          nil ->
            # create the direct and redirect
            ChannelService.add_direct(name, user_id, nil)
            direct = get_direct(user_id, name)
            show(conn, direct.channel)
          direct ->
            show(conn, direct.channel)
        end
    end
  end

  defp get_direct(user_id, name) do
    (from d in Direct,
      where: d.user_id == ^user_id and like(d.users, ^"%#{name}%"),
      preload: [:channel])
    |> Repo.one
  end

end
