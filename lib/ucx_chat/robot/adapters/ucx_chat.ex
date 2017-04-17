defmodule UcxChat.Robot.Adapters.UcxChat do
  use Hedwig.Adapter

  alias UcxChat.Robot.Adapters.UcxChat.{Connection}

  @doc false
  def init({robot, opts}) do
    {:ok, conn} = Connection.start(opts)
    # Kernel.send(self(), :connected)
    # {:ok, %{conn: conn, opts: opts, robot: robot}}
    Kernel.send(self(), :connected)
    {:ok, %{conn: conn, opts: opts, robot: robot}}
  end

  @doc false
  def handle_cast({:send, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  @doc false
  def handle_cast({:reply, %{user: user, text: text} = msg}, %{conn: conn} = state) do
    # Kernel.send(conn, {:reply, %{msg | text: "#{user}: #{text}"}})
    Kernel.send(conn, {:reply, %{msg | text: "#{text}"}})
    {:noreply, state}
  end

  @doc false
  def handle_cast({:emote, msg}, %{conn: conn} = state) do
    Kernel.send(conn, {:reply, msg})
    {:noreply, state}
  end

  @doc false
  def handle_info({:message, %{"text" => text, "user" => user, "channel" => channel}}, %{robot: robot} = state) do
    msg = %Hedwig.Message{
      ref: make_ref(),
      robot: robot,
      text: text,
      type: "chat",
      room: channel,
      user: %Hedwig.User{id: user.id, name: user.name}
    }

    Hedwig.Robot.handle_in(robot, msg)

    {:noreply, state}
  end

  def handle_info(:connected, %{robot: robot} = state) do
    :ok = Hedwig.Robot.handle_connect(robot)
    {:noreply, state}
  end
end
