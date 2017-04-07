defmodule UcxChat.File do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  use Arc.Ecto.Definition
  require Logger

  def __storage, do: Arc.Storage.Local

  @versions [:original, :poster]

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png .txt .text .doc .pdf .wav .mp3 .mp4 .mov .m4a .xls) |> Enum.member?(Path.extname(file.file_name))
  end

  def transform(:poster, {_, %{type: "video" <> _}} = item) do
    {:ffmpeg, fn(input, output) ->
      "-i #{input} -f image2 -ss 00:00:01.00 -vframes 1 -vf scale=-1:200 #{output}" end, :jpg}
  end
  def transform(:poster, {_, %{type: "image" <> _}}) do
    {:convert, "-strip -resize @80000 -format png", :png}
  end

  def filename(:poster, _params) do
    :poster
  end
  def filename(version, {_, %{file_name: file_name}}) do
    Logger.warn "version: #{inspect version}"
    String.replace(file_name, ~r(\.[^/.]+$), "")
  end
  def filename(version, %{file_name: file_name} = params) do
    Logger.warn "params: #{inspect params}"
    file_name
  end

  # Override the persisted filenames:
  # def filename(version, params) do
  #   Logger.warn "filename version: #{inspect version}, params: #{inspect params}"
  #   version
  # end

  def acl(_, _), do: :public_read

  # Override the storage directory:
  # def storage_dir(:preview, {_file, %{type: "image" <> _} = scope}) do
  #   "priv/static/uploads/#{scope.message_id}/thumb-"
  # end
  def storage_dir(_version, {_file, scope}) do
    storage_dir(scope)
    # Logger.warn "storage dir file: #{inspect file}, scope: #{inspect scope}"
    # Logger.warn "version: #{inspect version}"
    # "priv/static/uploads/#{scope.message_id}"

    # # "priv/uploads/#{scope.channel_id}"
    # # "/priv/uploads"
  end
  def storage_dir(scope) do
    "/priv/static/uploads/#{scope.message_id}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end
