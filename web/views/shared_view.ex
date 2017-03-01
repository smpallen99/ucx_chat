defmodule UcxChat.SharedView do
  use UcxChat.Utils
  alias UcxChat.{Client, Repo}
  require Logger

  def markdown(text), do: text

  def get_all_clients do
    Repo.all Client
  end
  def get_room_icon(chatd), do: chatd.room_map[chatd.channel.id][:room_icon]
  def get_room_status(chatd) do
    # Logger.error "get room status room_map: #{inspect chatd.room_map[chatd.channel.id]}"
    chatd.room_map[chatd.channel.id][:user_status]
  end
  def get_room_display_name(chatd), do: chatd.room_map[chatd.channel.id][:display_name]

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

  @regex1 ~r/^(.*?)(`(.*?)`)(.*?)$/
  @regex2 ~r/\A(```(.*)```)\z/Ums

  def format_quoted_code(string, true) do
    do_format_multi_line_quoted_code(string)
  end
  def format_quoted_code(string, _) do
    do_format_quoted_code(string, "")
  end

  def do_format_quoted_code(string, acc \\ "")
  def do_format_quoted_code("", acc), do: acc
  def do_format_quoted_code(nil, acc), do: acc
  def do_format_quoted_code(string, acc) do
    case Regex.run(@regex1, string) do
      nil -> acc <> string
      [_, head, _, quoted, tail] ->
        acc = acc <> head <> " " <> single_quote_code(quoted)
        do_format_quoted_code(tail, acc)
    end
  end

  def do_format_multi_line_quoted_code(string) do
    case Regex.run(@regex2, string) do
      nil -> string
      [_, _, quoted] ->
        multi_quote_code quoted
    end
  end

  # def multi_quote_code(quoted) do
  #   """
  #   <pre>
  #     <code class='code-colors'>
  #       #{quoted}
  #     </code>
  #   </pre>
  #   """
  # end
  def multi_quote_code(quoted) do
    "<pre><code class='code-colors'>#{quoted}</code></pre>"
  end

  def single_quote_code(quoted) do
    """
    <span class="copyonly">`</span>
    <span>
      <code class="code-colors inline">#{quoted}</code>
    </span>
    <span class="copyonly">`</span>
    """
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
