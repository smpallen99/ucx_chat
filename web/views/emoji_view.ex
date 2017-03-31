defmodule UcxChat.EmojiView do
  use UcxChat.Web, :view
  import UcxChat.Emoji


  def active_category(:people), do: " visible"
  def active_category(_), do: ""

  def active_filter(:people), do: " active"
  def active_filter(_), do: ""
end
