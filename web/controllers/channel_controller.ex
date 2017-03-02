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

    messages = MessageService.get_messages(channel.id)
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

  # def edit(conn, %{"id" => id}) do
  #   channel = Repo.get!(Channel, id)
  #   changeset = Channel.changeset(channel)
  #   render(conn, "edit.html", channel: channel, changeset: changeset)
  # end

  # def update(conn, %{"id" => id, "channel" => channel_params}) do
  #   channel = Repo.get!(Channel, id)
  #   changeset = Channel.changeset(channel, channel_params)

  #   case Repo.update(changeset) do
  #     {:ok, channel} ->
  #       conn
  #       |> put_flash(:info, "Channel updated successfully.")
  #       |> redirect(to: channel_path(conn, :show, channel))
  #     {:error, changeset} ->
  #       render(conn, "edit.html", channel: channel, changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   channel = Repo.get!(Channel, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(channel)

  #   conn
  #   |> put_flash(:info, "Channel deleted successfully.")
  #   |> redirect(to: channel_path(conn, :index))
  # end

  # def new(conn, _params) do
  #   changeset = Channel.changeset(%Channel{})
  #   render(conn, "new.html", changeset: changeset)
  # end

  # def create(conn, %{"channel" => channel_params}) do
  #   changeset = Channel.changeset(%Channel{}, channel_params)

  #   case Repo.insert(changeset) do
  #     {:ok, _channel} ->
  #       conn
  #       |> put_flash(:info, "Channel created successfully.")
  #       |> redirect(to: channel_path(conn, :index))
  #     {:error, changeset} ->
  #       render(conn, "new.html", changeset: changeset)
  #   end
  # end
end
