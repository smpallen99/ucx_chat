defmodule EmojiOne do

  import EmojiOne.Data

  require Logger

  @shortname Enum.to_list(?a..?z) ++ Enum.to_list(?A..?Z) ++ Enum.to_list(?0..?9) ++ '-_'
  @shortname_regex ~r/^:[a-zA-Z0-9_-]+:$/

  @default_src_path "/images"

  def shortname_to_image(text, opts \\ []) do
    opts = options opts

    opts_shortname = options opts, fn opts ->
      opts[:single_class] && Regex.match?(@shortname_regex, text) && shortname_unicode()[text]
    end

    if opts[:ascii] do
      do_ascii_to_image(text, opts)
    else
      text
    end
    |> parse_shortname("", "", opts_shortname)
  end

  defp parse_shortname("", "", acc, _),
    do: acc
  defp parse_shortname("", buffer, acc, _),
    do: acc <> buffer
  defp parse_shortname(":" <> head, "", acc, opts),
    do: parse_shortname(head, ":", acc, opts)
  defp parse_shortname(":" <> head, ":" <> buff, acc, opts) do
    shortname = ":" <> buff <> ":"
    if unicode = shortname_unicode()[shortname] do
      hash = shortname_hash()[shortname]
      parse_shortname(head, "", acc <> opts[:parser].(shortname, unicode, hash, opts), opts)
    else
      parse_shortname(head, "", acc <> shortname, opts)
    end
  end
  defp parse_shortname(<<ch::8>> <> head, "", acc, opts),
    do: parse_shortname(head, "", acc <> <<ch::8>>, opts)
  defp parse_shortname(<<ch::8>> <> head, buff, acc, opts) when ch in @shortname,
    do: parse_shortname(head, buff <> <<ch::8>>, acc, opts)
  defp parse_shortname(<<ch::8>> <> head, buff, acc, opts),
    do: parse_shortname(head, "", acc <> buff <> <<ch::8>>, opts)

  def replace_emoji(key, unicode, hash, opts) do
    extra_class = if ext = opts[:extra_class], do: " " <> ext, else: ""
    id_class = if cls = opts[:id_class], do: " " <> cls <> hash, else: ""
    cls = opts[:class] || "emojione"
    case opts[:wrapper] do
      nil ->
        src_path = opts[:src_path] || @default_src_path
        src_version = opts[:src_version] || ""
        img_type = opts[:img_type] || ".png"
        src = src_path <> "/#{hash}" <> img_type <> src_version
        ~s(<img class="#{cls}#{id_class}#{extra_class}" alt="#{key}" src="#{src}">)
      wrapper ->
        ~s(<#{wrapper} class="#{cls}#{id_class}#{extra_class}" title="#{key}">#{unicode}</#{wrapper}>)
    end
  end

  def ascii_to_image(text, opts \\ []) do
    do_ascii_to_image text, options(opts)
  end

  defp do_ascii_to_image(text, opts) do
    keys = ascii_keys()
    tokens = String.split(text, " ")
    opts = options opts, fn opts ->
      opts[:single_class] && length(tokens) == 1
    end

    tokens
    |> Enum.map(fn text ->
      if text in keys, do: opts[:parser].(text, ascii_unicode()[text], ascii_hash()[text], opts), else: text
    end)
    |> Enum.join(" ")
  end

  defp options(opts) do
    :ucx_chat
    |> Application.get_env(:emoji_one, [])
    |> Enum.into(%{})
    |> Map.merge(Enum.into(opts, %{}))
    |> Map.put_new(:parser, &replace_emoji/4)
    |> Map.put_new(:extra_class, "")
  end

  defp options(opts, single_fun) do
    if single_fun.(opts) do
      sc = opts[:single_class] || ""
      update_in(opts, [:extra_class], fn
        "" -> sc
        ext -> ext <> " " <> sc
      end)
    else
      opts
    end
  end

end

