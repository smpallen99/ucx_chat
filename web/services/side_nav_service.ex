defmodule UcxChat.SideNavService do
  use UcxChat.Web, :service

  alias UcxChat.ServiceHelpers, as: Helpers
  alias UcxChat.{ChatDat, Channel, ChannelService, User, Direct, Subscription}

  def render_rooms_list(channel_id, user_id) do
    user = Helpers.get_user! user_id
    channel = if channel_id, do: Helpers.get(Channel, channel_id), else: nil

    chatd = ChatDat.new(user, channel)

    "rooms_list.html"
    |> UcxChat.SideNavView.render(chatd: chatd)
    |> Helpers.safe_to_string
  end

  def render_more_channels(user_id) do
    user = Helpers.get_user! user_id
    channels =
      user
      |> ChannelService.get_side_nav_rooms

    "list_combined_flex.html"
    |> UcxChat.SideNavView.render(channels: channels, current_user: user)
    |> Helpers.safe_to_string
  end

  def render_more_users(user_id) do
    user = Helpers.get_user! user_id
    users =
      Repo.all(from u in User,
        left_join: d in Direct, on: u.id == d.user_id and d.users == ^(user.username),
        left_join: s in Subscription, on: s.user_id == ^user_id and s.channel_id == d.channel_id,
        # left_join: c in Channel, on: c.id == d.channel_id,
        where: u.id != ^user_id,
        order_by: [asc: u.username],
        preload: [:roles],
        select: {u, s})
      |> Enum.reject(fn {user, _} -> User.has_role?(user, "bot") || user.active != true end)
      |> Enum.map(fn
        {user, nil} -> struct(user, subscription_hidden: nil, status: UcxChat.PresenceAgent.get(user.id))
        {user, sub} -> struct(user, subscription_hidden: sub.hidden, status: UcxChat.PresenceAgent.get(user.id))
      end)

    "list_users_flex.html"
    |> UcxChat.SideNavView.render(users: users, current_user: user)
    |> Helpers.safe_to_string
  end

end
