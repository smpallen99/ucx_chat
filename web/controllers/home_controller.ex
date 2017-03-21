defmodule UcxChat.HomeController do
  use UcxChat.Web, :controller
  require Logger
  alias UcxChat.{ChatDat}
  alias UcxChat.ServiceHelpers, as: Helpers

  def index(conn, _params) do
    user = Helpers.get_user!(Coherence.current_user(conn) |> Map.get(:id))

    chatd = ChatDat.new(user)
    render conn, "index.html", chatd: chatd
  end

end
