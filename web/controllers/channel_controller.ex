defmodule UcxChat.ChannelController do
  use UcxChat.Web, :controller

  import Ecto.Query

  require Logger

  alias UcxChat.Channel, as: Channel
  alias UcxChat.{MessageService, ChannelService, Message, ChatDat}

  def index(conn, _params) do
    show(conn, UcxChat.Channel |> Ecto.Query.first |> Repo.one)
  end

  def show(conn, %Channel{} = channel) do
    user =
      conn
      |> Coherence.current_user
      |> Repo.preload([:client])

    messages = MessageService.get_messages(channel.id)
    chatd = ChatDat.new(user.client, channel, messages)
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
