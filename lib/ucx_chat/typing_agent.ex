defmodule UcxChat.TypingAgent do
  @name __MODULE__
  # @audit_secs 120

  def start_link do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def start_typing(channel_id, %{} = user),
    do: start_typing(channel_id, user.id, user.username)

  def start_typing(channel_id, user_id, username) do
    spawn fn ->
      :timer.sleep(60000)
      stop_typing(channel_id, user_id)
    end

    Agent.update(@name, fn state ->
      update_in state, [channel_id], fn
        nil -> %{user_id => username}
        map -> put_in(map, [user_id], username)
      end
    end)
  end

  def get_typing_names(channel_id) do
    get_typing(channel_id)
    |> Enum.map(fn {_, name} -> name end)
  end

  def get_typing(channel_id) do
    Agent.get(@name, &(get_in &1, [channel_id])) || []
  end

  def stop_typing(channel_id, %{} = user),
    do: stop_typing(channel_id, user.id)

  def stop_typing(channel_id, user_id) do
    Agent.update(@name, fn data ->
      update_in data, [channel_id], &(if &1, do: Map.delete(&1, user_id))
    end)
  end

  def get do
    Agent.get @name, &(&1)
  end

  def get_pid do
    Agent.get @name, fn _ -> self() end
  end

end
