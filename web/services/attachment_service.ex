defmodule UcxChat.AttachmentService do
  use UcxChat.Web, :service

  alias UcxChat.{Attachment, Message}
  alias Ecto.Multi

  require Logger

  def insert_attachment(params) do
    message_params = %{channel_id: params["channel_id"], body: "", sequential: false, user_id: params["user_id"]}
    params = Map.delete params, "user_id"
    multi =
      Multi.new
      |> Multi.insert(:message, Message.changeset(%Message{}, message_params))
      |> Multi.run(:attachment, &do_insert_attachment(&1, params))

    Repo.transaction(multi)
  end

  defp do_insert_attachment(%{message: %{id: id}}, params) do
    changeset = Attachment.changeset(%Attachment{}, Map.put(params, "message_id", id))
    Repo.insert changeset
    # case Repo.insert changeset do
    #   {:ok, attachment} ->
    #   {:error, changeset} ->
    # end
  end

end
