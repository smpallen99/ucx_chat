defmodule UcxChat.ChannelControllers do
  def route_name(mod) do
    mod
    |> inspect
    |> String.replace(~r/ChannelController$/, "")
    |> String.downcase
  end
end
