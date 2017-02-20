defmodule UcxChat.ChannelRouter do
  use ChannelRouter

  @module __MODULE__

  def route_post(socket, "/typing", params) do
    # module and action are build by the post macro
    apply(UcxChat.TypingChannelController, :create, [socket, params])
  end

  def route_delete(socket, "/typing", params) do
    apply(UcxChat.TypingChannelController, :delete, [socket, params])
  end

  def route_put(socket, "/slashcommand/" <> command, params) do
    apply(UcxChat.SlashCommandChannelController, :execute, [socket, Map.put(params, "command", command)])
  end

  # def routes do
  #   [
  #     {:post, "/", UcxChat.TypingChannelController, :create},
  #     {:delete, "/", UcxChat.TypeingChannelController, :delete}
  #   ]
  # end
end
