defmodule UcxChat.AttachmentController do
  use UcxChat.Web, :controller

  # alias UcxChat.{Channel, User, Direct, ChannelService}
  alias UcxChat.{Attachment, AttachmentService}

  import Ecto.Query

  require Logger

  def create(conn, params) do
    Logger.warn "attachment params: #{inspect params}"
    # Logger.warn "conn: #{inspect conn}"
    # changeset = Attachment.changeset(%Attachment{}, params)
    case AttachmentService.insert_attachment params do
      {:ok, attachment} ->
        # Logger.warn "Repo.insert ok, #{inspect attachment}"
        # text conn, "ok"
        render conn, "success.json", %{}
      {:error, changeset} ->
        # Logger.error "error changeset: #{inspect changeset}"
        render conn, "error.json", %{}
      other ->
        # Logger.warn "create result other: #{inspect other}"
        render conn, "success.json", %{}
    end
  end

end
