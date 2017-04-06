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
    |> media_types(attachment)
    |> Enum.into(%{
      id: attachment.id,
      # file_name: attachment.file[:file_name],
      file_name: UcxChat.File.filename(:original, attachment),
      url: UcxChat.File.url({attachment.file, attachment}) |> String.replace("/priv/static", ""),
      description: attachment.description,
      loaded: true,   # this should be based on config
    })
  end

  defp media_types("image/" <> type, attachment) do
    poster_url = UcxChat.File.url({attachment.file, attachment}, :poster) |> String.replace("/priv/static", "")
    [media_type: :image, image_type: type, poster_url: poster_url]
  end
  defp media_types(type = "audio/" <> _, _) do
    [media_type: :audio, audio_type: type]
  end
  defp media_types(type = "video/" <> _, attachment) do
    poster_url = UcxChat.File.url({attachment.file, attachment}, :poster) |> String.replace("/priv/static", "")
    [media_type: :video, video_type: type, poster_url: poster_url]
  end
  defp media_types(other, _) do
    [media_type: :other, other_type: other]
  end

end

