defmodule UcxChat.TypingAgent do
  @name __MODULE__
  @audit_secs 120

  def start_link do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def start_typing(channel_id, %{} = client),
    do: start_typing(channel_id, client.id, client.nickname)

  def start_typing(channel_id, client_id, nickname) do
    spawn fn ->
      :timer.sleep(60000)
      stop_typing(channel_id, client_id)
    end

    Agent.update(@name, fn state ->
      update_in state, [channel_id], fn
        nil -> %{client_id => nickname}
        map -> put_in(map, [client_id], nickname)
      end
    end)
  end

  def get_typing_names(channel_id) do
    get_typing(channel_id)
    |> Enum.map(fn {_, name} -> name end)
  end

  def get_typing(channel_id) do
    Agent.get(@name, &(get_in &1, [channel_id]))
  end

  def stop_typing(channel_id, %{} = client),
    do: stop_typing(channel_id, client.id)

  def stop_typing(channel_id, client_id) do
    Agent.update(@name, fn data ->
      update_in data, [channel_id], &(if &1, do: Map.delete(&1, client_id))
    end)
  end

  def get do
    Agent.get @name, &(&1)
  end

  def get_pid do
    Agent.get fn _ -> self() end
  end

end
