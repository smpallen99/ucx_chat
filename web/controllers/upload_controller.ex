defmodule UcxChat.UploadController do
  use UcxChat.Web, :controller

  # alias UcxChat.{Channel, User, Direct, ChannelService}
  alias UcxChat.{Upload, Message}

  import Ecto.Query

  require Logger

  def create(conn, params) do
    Logger.warn "upload params: #{inspect params}"
    changeset = Message.changeset(%Message{}, params)
    case Repo.insert changeset do
      {:ok, update} ->
        Logger.warn "Repo.insert ok, #{update.id}"
        render conn, "success.json", %{}
      {:error, changeset} ->
        Logger.error "error changeset: #{inspect changeset}"
        render conn, "error.json", %{}
    end
  end

end
