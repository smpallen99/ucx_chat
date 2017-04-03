defmodule UcxChat.UploadView do
  use UcxChat.Web, :view

  def render("success.json", opts) do
    %{success: true}
  end
  def render("error.json", opts) do
    %{error: true}
  end
end

