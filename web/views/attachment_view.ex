defmodule UcxChat.AttachmentView do
  use UcxChat.Web, :view

  def render("success.json", opts) do
    %{success: true}
  end
  def render("error.json", opts) do
    %{error: true}
  end

  def get_attachment(attachment) do
    %{
      file_name: attachment.file[:file_name],
      url: UcxChat.File.url({attachment.file, attachment}) |> String.replace("/priv/static", ""),
      description: attachment.description
    }
  end
end

