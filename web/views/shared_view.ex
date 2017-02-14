defmodule UcxChat.SharedView do
  alias UcxChat.{Client, Repo}

  def markdown(text), do: text

  def get_all_clients do
    Repo.all Client
  end
  def get_room_icon(chatd), do: chatd.room_map[chatd.channel.id][:room_icon]
end
