defmodule UcxChat.RobotService do
  require Logger

  def new_message(body, channel, user) do
    Kernel.send :robot, {:message, body, channel, user}
  end

end
