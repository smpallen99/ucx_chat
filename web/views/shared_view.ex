defmodule UcxChat.SharedView do
  use UcxChat.Utils
  alias UcxChat.{Client, Repo}

  def markdown(text), do: text

  def get_all_clients do
    Repo.all Client
  end
  def get_room_icon(chatd), do: chatd.room_map[chatd.channel.id][:room_icon]

  def hidden_on_nil(test, prefix \\ "")
  def hidden_on_nil(_test, ""), do: " hidden"
  def hidden_on_nil(test, prefix) when is_falsy(test), do: " #{prefix}hidden"
  def hidden_on_nil(_, _), do: ""

  def map_field(map, field, default \\ "")
  def map_field(%{} = map, field, default), do: Map.get(map, field, default)
  def map_field(_, _, default), do: default

  def get_ftab_open_class(nil), do: ""
  def get_ftab_open_class(_), do: "opened"

  def get_room_notification_sounds do
    [None: "one", "Door (Default)": "door", Beep: "beep", Chelle: "chelle", Ding: "ding",
     Droplet: "droplet", Highbell: "highbell", Seasons: "seasons"]
  end
  def get_message_notification_sounds do
    [None: "one", "Chime (Default)": "chime", Beep: "beep", Chelle: "chelle", Ding: "ding",
     Droplet: "droplet", Highbell: "highbell", Seasons: "seasons"]
  end

  defmacro gt(text, opts \\ []) do
    quote do
      gettext(unquote(text), unquote(opts))
    end
  end
  defmacro sigil_g(text, _) do
    quote do
      gettext(unquote(text))
    end
  end
end
