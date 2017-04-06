defmodule UcxChat.AttachmentController do
  use UcxChat.Web, :controller

  # alias UcxChat.{Channel, User, Direct, ChannelService}
  alias UcxChat.{AttachmentService}

  require Logger

  def create(conn, params) do
    # Logger.warn "attachment params: #{inspect params}"
    case AttachmentService.insert_attachment params do
      {:ok, _attachment, _message} ->
        render conn, "success.json", %{}
      {:error, _changeset} ->
        render conn, "error.json", %{}
      _other ->
        render conn, "success.json", %{}
    end
  end

end
