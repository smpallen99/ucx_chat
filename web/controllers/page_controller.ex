defmodule UcxChat.PageController do
  use UcxChat.Web, :controller
  require Logger

  def index(conn, _params) do
    user = Coherence.current_user(conn)
    |> Repo.preload([:client])
    channel = UcxChat.ChatChannel |> Ecto.Query.first |> Repo.one
    Logger.info "user: #{inspect user}"
    render conn, "index.html", user: user, channel: channel
  end
end
