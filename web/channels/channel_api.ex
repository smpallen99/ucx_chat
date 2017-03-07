defmodule UcxChat.ChannelApi do

  defmacro __using__(opts \\ []) do
    quote do
      opts = unquote(opts)
      import unquote(__MODULE__)
      if Keyword.get(opts, :debug, :true) do
        require Logger
        def debug, do: true
      else
        def debug, do: false
      end
      # import Phoenix.Channel, except: [handle_in: 3]
    end
  end

  defmacro debug(event, params, msg \\ "") do
    name = __CALLER__.function |> elem(0) |> to_string
    quote location: :keep do
      msg1 = case unquote(msg) do
        "" -> ""
        mg -> mg <> ", "
      end

      if debug() do
        Logger.info "%% " <> inspect(__MODULE__) <> ".#{unquote(name)} #{unquote(event)}: #{msg1}params: #{inspect unquote(params)}"
      end
    end
  end
  defmacro warn(event, params, msg \\ "") do
    name = __CALLER__.function |> elem(0) |> to_string
    quote location: :keep do
      msg1 = case unquote(msg) do
        "" -> ""
        mg -> mg <> ", "
      end

      if debug() do
        Logger.warn "%% " <> inspect(__MODULE__) <> ".#{unquote(name)} #{unquote(event)}: #{msg1}params: #{inspect unquote(params)}"
      end
    end
  end

  # defmacro handle_in(ev, msg, sock, block) do
  #   quote do
  #     if debug() do
  #       Logger.debug inspect(__MODULE__) <> ".handle_id #{unquote(ev)}: #{inspect unquote(msg)}"
  #     end
  #     Logger.warn "............ steve was here"
  #     Phoenix.Channel.handle_in(unquote(ev), unquote(msg), unquote(sock), block)
  #   end
  # end

end
