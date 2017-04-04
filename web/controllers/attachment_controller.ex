defmodule UcxChat.AttachmentController do
  use UcxChat.Web, :controller

  # alias UcxChat.{Channel, User, Direct, ChannelService}
  alias UcxChat.{Attachment, AttachmentService}

  import Ecto.Query

  require Logger

  def create(conn, params) do
    # Logger.warn "attachment params: #{inspect params}"
    case AttachmentService.insert_attachment params do
      {:ok, attachment, message} ->
        render conn, "success.json", %{}
      {:error, changeset} ->
        render conn, "error.json", %{}
      other ->
        render conn, "success.json", %{}
    end
  end

end
