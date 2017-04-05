defmodule UcxChat.EmojiView do
  use UcxChat.Web, :view
  import UcxChat.Emoji


  def active_category(true), do: " visible"
  def active_category(_), do: ""

  def active_filter(true), do: " active"
  def active_filter(_), do: ""

  def tone_append(0), do: ""
  def tone_append(tone), do: "_tone#{tone}"
  def get_tones, do: tone_list()
end
