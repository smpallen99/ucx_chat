defmodule UcxChat.AttachmentService do
  use UcxChat.Web, :service

  alias UcxChat.{Attachment, Message, MessageService, Channel, Settings}
  alias Ecto.Multi

  require Logger

  def insert_attachment(params) do
    message_params = %{channel_id: params["channel_id"], body: "", sequential: false, user_id: params["user_id"]}
    params = Map.delete params, "user_id"
    multi =
      Multi.new
      |> Multi.insert(:message, Message.changeset(%Message{}, message_params))
      |> Multi.run(:attachment, &do_insert_attachment(&1, params))

    case Repo.transaction(multi) do
      {:ok, %{message: message}} = ok ->
        broadcast_message(message)
        ok
      error ->
        error
    end
  end

  defp do_insert_attachment(%{message: %{id: id} = message}, params) do
    changeset = Attachment.changeset(%Attachment{}, Map.put(params, "message_id", id))
    case Repo.insert changeset do
      {:ok, attachment} ->
        Logger.warn ".     . . .attachment: #{inspect attachment}"
        scope = %{id: attachment.message_id}
        res = UcxChat.File.store({attachment.file_name, scope})
        Logger.warn ".............. res: #{inspect res}"
        {:ok, %{attachment: attachment, message: message}}
      error -> error
    end
  end

  defp broadcast_message(message) do
    channel = Helpers.get Channel, message.channel_id
    html =
      message
      |> Repo.preload(MessageService.preloads())
      |> MessageService.render_message
    MessageService.broadcast_message(message.id, channel.name, message.user_id, html)
  end

  def count(message_id) do
    Repo.one from a in Attachment,
      where: a.message_id == ^message_id,
      select: count(a.id)
  end

  def allowed?(channel) do
    Settings.file_uploads_enabled() && ((channel.type != 2) || Settings.dm_file_uploads())
  end
end
