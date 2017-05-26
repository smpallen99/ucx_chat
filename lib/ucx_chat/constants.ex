defmodule Constants do
  @moduledoc """
  An alternative to use @constant_name value approach to defined reusable
  constants in elixir.

  This module offers an approach to define these in a
  module that can be shared with other modules. They are implemented with
  macros so they can be used in guards and matches

  ## Examples:

  Create a module to define your shared constants

      defmodule MyConstants do
        use Constants

        define something,   10
        define another,     20
      end

  Use the constants

      defmodule MyModule do
        require MyConstants
        alias MyConstants, as: Const

        def myfunc(item) when item == Const.something, do: Const.something + 5
        def myfunc(item) when item == Const.another, do: Const.another
      end

  """

 defmacro __using__(_opts) do
    quote do
      import Constants
    end
  end

  @doc "Define a constant"
  defmacro constant(name, value) do
    quote do
      defmacro unquote(name), do: unquote(value)
    end
  end

  @doc "Define a constant. An alias for constant"
  defmacro define(name, value) do
    quote do
      constant unquote(name), unquote(value)
    end
  end

  @doc """
    Import an hrl file.

    Create constants for each -define(NAME, value).
  """
  defmacro import_hrl(file_name) do
    list = parse_file file_name
    quote bind_quoted: [list: list] do
      for {name, value} <- list do
        defmacro unquote(name)(), do: unquote(value)
      end
    end
  end

  defp parse_file(file_name) do
    for line <- File.stream!(file_name, [], :line) do
      parse_line line
    end
    |> Enum.filter(&(not is_nil(&1)))
  end

  defp parse_line(line) do
    case Regex.run ~r/-define\((.+),(.+)\)\./, line do
      nil -> nil
      [_, name, value] ->
        {String.strip(name) |> String.downcase |> String.to_atom, String.strip(value) |> parse_value}
      _ -> nil
    end
  end

  defp parse_value(string) do
    case Integer.parse string do
      :error -> filter_string(string)
      {num, _} -> num
    end
  end

  defp filter_string(string), do: String.replace(string, "\"", "")
end
