defmodule UcxChat.HomeController do
  use UcxChat.Web, :controller
  require Logger
  alias UcxChat.{Repo, User, ChatDat}
  alias UcxChat.ServiceHelpers, as: Helpers
  import Ecto.Query

  def index(conn, _params) do
    user = Helpers.get_user!(Coherence.current_user(conn) |> Map.get(:id))

    chatd = ChatDat.new(user)
    render conn, "index.html", chatd: chatd
  end

  def switch_user(conn, %{"user" => username}) do
    Logger.warn "conn: #{inspect conn}"
    new_user =
      User
      |> where([u], u.username == ^username)
      |> Repo.one!
    conn
    |> Helpers.logout_user()
    |> Helpers.login_user(new_user)
    |> redirect(to: "/")
  end
end
