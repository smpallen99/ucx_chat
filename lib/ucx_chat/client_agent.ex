defmodule UcxChat.ClientAgent do
  @name __MODULE__
  alias UcxChat.Client
  require Logger

  def start_link do
    # Logger.warn "starting #{@name}"
    Agent.start_link(fn -> init_state() end, name: @name)
  end

  def init_state, do: %{ftab: %{}}

  def open_ftab(%Client{id: id}, channel_id, name, view), do: open_ftab(id, channel_id, name, view)
  def open_ftab(client_id, channel_id, name, view) do
    Agent.update(@name, fn state ->
      args = if view, do: %{elem(view, 0) => elem(view, 1)}, else: %{}
      update_in state, [:ftab, {client_id, channel_id}], fn _ -> %{title: name, args: args} end
    end)
  end

  def close_ftab(%Client{id: id}, channel_id), do: close_ftab(id, channel_id)
  def close_ftab(client_id, channel_id) do
    Agent.update(@name, fn state ->
      update_in state, [:ftab, {client_id, channel_id}], fn _ -> nil end
    end)
  end

  def get_ftab(%Client{id: id}, channel_id), do: get_ftab(id, channel_id)
  def get_ftab(client_id, channel_id) do
    # Logger.warn "get_ftab client_id: #{inspect client_id}, channel_id: #{inspect channel_id}"
    # Logger.warn inspect get()
    Agent.get(@name, fn state -> get_in state, [:ftab, {client_id, channel_id}] end)
  end

  def get() do
    Agent.get(@name, fn state -> state end)
  end

  def clear() do
    Agent.update @name, fn _ -> init_state() end
  end
end
