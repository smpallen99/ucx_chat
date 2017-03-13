defmodule UcxChat.AvatarController do
  use UcxChat.Web, :controller
  import UcxChat.AvatarService

  def show(conn, %{"username" => username}) do
    # xml = UcxChat.AvatarService.avatar_initials(username)
    conn
    |> put_layout(:none)
    |> put_resp_content_type("image/svg+xml")
    |> render("show.xml", color: get_color(username), initials: get_initials(username))
  end

end
