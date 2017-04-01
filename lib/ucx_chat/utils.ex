defmodule UcxChat.Utils do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro is_falsey(value) do
    quote do
      (unquote(value) == nil or unquote(value) == false)
    end
  end
  defmacro is_falsy(value) do
    quote do
      is_falsey(unquote(value))
    end
  end

  defmacro is_truthy(value) do
    quote do
      (not is_falsey(unquote(value)))
    end
  end

  def deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  # Key exists in both maps, and both values are maps as well.
  # These can be merged recursively.
  defp deep_resolve(_key, left = %{}, right = %{}) do
    deep_merge(left, right)
  end

  # Key exists in both maps, but at least one of the values is
  # NOT a map. We fall back to standard merge behavior, preferring
  # the value on the right.
  defp deep_resolve(_key, _left, right) do
    right
  end

  def to_camel_case(atom) when is_atom(atom), do: atom |> to_string |> to_camel_case
  def to_camel_case(string) do
    string
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("")
  end

end
