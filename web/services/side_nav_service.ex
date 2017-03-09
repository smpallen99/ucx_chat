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

  def render_more_channels(user_id) do
    user = Helpers.get_user! user_id
    channels = ChannelService.get_side_nav_rooms(user)

    "list_combined_flex.html"
    |> UcxChat.SideNavView.render(channels: channels, current_user: user)
    |> Phoenix.HTML.safe_to_string
  end

end
