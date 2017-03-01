defmodule UcxChat.ChannelMonitor do
  use GenServer

  def monitor(server_name, pid, mfa) do
    GenServer.call(server_name, {:monitor, pid, mfa})
  end

  def demonitor(server_name, pid) do
    GenServer.call(server_name, {:demonitor, pid})
  end

  def status(server_name) do
    GenServer.call(server_name, :status)
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init(_) do
    Process.flag(:trap_exit, true)
    {:ok, %{channels: %{}}}
  end

  def handle_call({:monitor, pid, mfa}, _from, state) do
    Process.link(pid)
    {:reply, :ok, put_channel(state, pid, mfa)}
  end

  def handle_call({:demonitor, pid}, _from, state) do
    case state.channels[pid] do
      nil ->
        {:reply, :ok, state}
      _  ->
        Process.unlink(pid)
        {:reply, :ok, drop_channel(state, pid)}
    end
  end

  def handle_call(:status, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, pid, _reason}, state) do
    case state.channels[pid] do
      nil ->
        {:noreply, state}
      {mod, func, args} ->
        Task.start_link(fn -> apply(mod, func, [pid|args]) end)
        {:noreply, drop_channel(state, pid)}
    end
  end

  defp drop_channel(state, pid) do
    update_in state, [:channels], &Map.delete(&1, pid)
  end

  defp put_channel(state, pid, mfa) do
    put_in state, [:channels, pid], mfa
  end
end
