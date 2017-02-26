defmodule UcxChat.SideNavView do
  use UcxChat.Web, :view
  alias UcxChat.Client

  def chat_room_item_li_class(item) do
    acc = "link-room-#{item[:name]} background-transparent-darker-hover"
    with acc <- if(item[:active], do: acc <> " active", else: acc),
         do: if(item[:alert], do: acc <> " has-alert", else: acc)
  end

  def is_active(items) do
    if Enum.reduce(items, false, &(&2 || &1[:is_active])), do: " active", else: ""
  end

  def get_registered_menus(%Client{}), do: []

  def get_user_status(%Client{} = client) do
    "status-" <> get_visual_status(client)
  end

  def get_visual_status(%Client{} = client) do
    client.chat_status
  end

  def get_user_avatar(%Client{}) do
    ""
  end

  def get_user_name(%Client{} = client), do: client.nickname
  def show_admin_option(%Client{}), do: true
end

