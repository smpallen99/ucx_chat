defmodule EmojiOne do

  import EmojiOne.Data

  @shortname Enum.to_list(?a..?z) ++ Enum.to_list(?A..?Z) ++ Enum.to_list(?0..?9) ++ '-_'

  def shortname_to_image(text, parser \\ &replace_emoji/3) do
    parse_shortname text, "", "", parser
  end

  defp parse_shortname("", "", acc, _),
    do: acc
  defp parse_shortname("", buffer, acc, _),
    do: acc <> buffer
  defp parse_shortname(":" <> head, "", acc, parser),
    do: parse_shortname(head, ":", acc, parser)
  defp parse_shortname(":" <> head, ":" <> buff, acc, parser) do
    shortname = ":" <> buff <> ":"
    unicode = shortname_unicode()[shortname]
    hash = shortname_hash()[shortname]
    parse_shortname(head, "", acc <> parser.(shortname, unicode, hash), parser)
  end
  defp parse_shortname(<<ch::8>> <> head, "", acc, parser),
    do: parse_shortname(head, "", acc <> <<ch::8>>, parser)
  defp parse_shortname(<<ch::8>> <> head, buff, acc, parser) when ch in @shortname,
    do: parse_shortname(head, buff <> <<ch::8>>, acc, parser)
  defp parse_shortname(<<ch::8>> <> head, buff, acc, parser),
    do: parse_shortname(head, "", acc <> buff <> <<ch::8>>, parser)

  def replace_emoji(key, unicode, hash) do
    ~s(<span class="emojione emojione-#{hash}" title="#{key}">#{unicode}</span>)
  end

  def ascii_to_image(text, parser \\ &replace_emoji/3) do
    keys = ascii_keys()
    text
    |> String.split(" ")
    |> Enum.map(fn text ->
      if text in keys do
        parser.(text, ascii_unicode()[text], ascii_hash()[text])
      else
        text
      end
    end)
    |> Enum.join(" ")
  end

end

