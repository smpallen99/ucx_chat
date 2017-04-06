defmodule UcxChat.DirectController do
  use UcxChat.Web, :controller

  alias UcxChat.Channel
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger

  def show(conn, %{"id" => id}) do
    Logger.warn "direct show id: #{inspect id}"

    channel =
      Channel
      |> where([c], c.name == ^id)
      |> Repo.one!

    user =
      conn
      |> Coherence.current_user
      |> Repo.preload(Helpers.default_user_preloads())

    conn
    |> put_view(UcxChat.PageView)
    |> render("index.html", user: user, channel: channel)
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
end
