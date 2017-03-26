defmodule UcxChat.SideNavView do
  use UcxChat.Web, :view
  alias UcxChat.User
  require Logger

  def chat_room_item_li_class(item) do
    acc = "link-room-#{item[:name]} background-transparent-darker-hover"
    with acc <- if(item[:open], do: acc <> " active", else: acc),
         acc <- if(item[:has_unread], do: acc <> " has-unread has-alert", else: acc),
         do: if(item[:alert], do: acc <> " has-alert", else: acc)
  end

  def is_active(items) do
    if Enum.reduce(items, false, &(&2 || &1[:is_active])), do: " active", else: ""
  end

  def get_registered_menus(%User{}), do: []

  def get_user_status(%User{} = user) do
    "status-" <> get_visual_status(user)
  end

  def get_visual_status(%User{} = user) do
    user.chat_status
  end

  def get_user_avatar(%User{}) do
    ""
  end

  def get_user_name(%User{} = user), do: user.username

  def show_admin_option(%User{} = user) do
    user = UcxChat.Repo.preload(user, [:roles])
    list = ~w(view-statistics  view-room-administration view-user-administration view-privileged-setting)
    UcxChat.Permission.has_at_least_one_permission?(user, list)
  end
end

