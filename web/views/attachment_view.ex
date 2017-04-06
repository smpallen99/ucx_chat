defmodule UcxChat.AttachmentView do
  use UcxChat.Web, :view

  def render("success.json", _opts) do
    %{success: true}
  end
  def render("error.json", _opts) do
    %{error: true}
  end

  def get_attachment(attachment) do
    attachment.type
    |> media_types
    |> Enum.into(%{
      id: attachment.id,
      file_name: attachment.file[:file_name],
      url: UcxChat.File.url({attachment.file, attachment}) |> String.replace("/priv/static", ""),
      description: attachment.description,
      loaded: true,   # this should be based on config
    })
  end

  defp media_types("image/" <> type) do
    [media_type: :image, image_type: type]
  end
  defp media_types(type = "audio/" <> _) do
    [media_type: :audio, audio_type: type]
  end
  defp media_types(type = "video/" <> _) do
    [media_type: :video, video_type: type]
  end
  defp media_types(other) do
    [media_type: :other, other_type: other]
  end

end

