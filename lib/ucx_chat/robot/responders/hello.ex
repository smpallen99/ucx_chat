defmodule UcxChat.Robot.Responders.Hello do
  @moduledoc """
  Hello, Hello

  """

  use Hedwig.Responder
  require Logger

  @messages [
    "Good day",
    "Well hello there",
    "Marnin'",
    "Good 'aye!",
    "G'day"
  ]

  @usage """
  <text> (hello) - Replies with Hi there name
  """
  # hear ~r/(hello)|(good day)/i, msg do
  hear ~r/good day/i, msg do
    reply_msg msg
  end
  hear ~r/hello/i, msg do
    reply_msg msg
  end

  defp reply_msg(msg) do
    name = msg.user.name |> String.split(" ") |> hd
    reply msg, "#{random @messages} #{name}!"
  end
end
