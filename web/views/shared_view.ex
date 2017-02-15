defmodule UcxChat.SharedView do
  use UcxChat.Utils
  alias UcxChat.{Client, Repo}

  def markdown(text), do: text

  def get_all_clients do
    Repo.all Client
  end
  def get_room_icon(chatd), do: chatd.room_map[chatd.channel.id][:room_icon]

  def hidden_on_nil(test, prefix \\ "")
  def hidden_on_nil(test, ""), do: " hidden"
  def hidden_on_nil(test, prefix) when is_falsy(test), do: " #{prefix}hidden"
  def hidden_on_nil(_, _), do: ""

  def map_field(map, field, default \\ "")
  def map_field(%{} = map, field, default), do: Map.get(map, field, default)
  def map_field(_, _, default), do: default
end
