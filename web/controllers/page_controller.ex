defmodule UcxChat.PageController do
  use UcxChat.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
