defmodule UcxChat.SideNavView do
  use UcxChat.Web, :view

  def chat_room_item_li_class(item) do
    acc = "link-room-#{item[:name]} background-transparent-darker-hover"
    with acc <- if(item[:active], do: acc <> " active", else: acc),
         do: if(item[:alert], do: acc <> " has_alert", else: acc)
  end

  def is_active(items) do
    if Enum.reduce(items, false, &(&2 || &1[:is_active])), do: " active", else: ""
  end

  def get_registered_menus(_user), do: []

  def get_user_status(user) do
    "status-" <> get_visual_status(user)
  end

  def get_visual_status(user) do
    user.client.chat_status
  end

  def get_user_avatar(_user) do
    ""
  end

  def get_user_name(user), do: user.client.nickname
  def show_admin_option(_user), do: false
end

