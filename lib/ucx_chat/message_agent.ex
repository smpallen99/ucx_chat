defmodule UcxChat.MessageAgent do
  @name __MODULE__
  # require Logger

  def start_link do
    # Logger.warn "starting #{@name}"
    Agent.start_link(fn -> init_state() end, name: @name)
  end

  def init_state, do: %{previews: %{}}

  def put_preview(_url, "" = html), do: html
  def put_preview(url, html) do
    Agent.update @name, fn state ->
      put_in state, [:previews, url], html
    end
    html
  end

  def get_preview(url) do
    Agent.get @name, fn state ->
      get_in state, [:previews, url]
    end
  end

  def get do
    Agent.get @name, &(&1)
  end

end
