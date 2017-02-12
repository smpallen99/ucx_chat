defmodule UcxChat.SideNavView do
  use UcxChat.Web, :view

  def chat_room_item_li_class(item) do
    acc = "link-room-#{item[:rid]} background-transparent-darker-hover"
    with acc <- if(item[:active], do: acc <> " active", else: acc),
         do: if(item[:alert], do: acc <> " has_alert", else: acc)
  end
end
