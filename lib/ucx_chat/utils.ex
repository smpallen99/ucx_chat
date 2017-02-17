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


end
