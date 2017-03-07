defmodule UcxChat.SideNavService do
  alias UcxChat.ServiceHelpers, as: Helpers
  alias UcxChat.{ChatDat, Channel, SideNavView, Repo, ChannelService}

  def render_rooms_list(channel_id, user_id) do
    user = Helpers.get_user! user_id
    channel = Helpers.get!(Channel, channel_id)

    chatd = ChatDat.new(user, channel)

    "rooms_list.html"
    |> UcxChat.SideNavView.render(chatd: chatd)
    |> Phoenix.HTML.safe_to_string
  end

end
