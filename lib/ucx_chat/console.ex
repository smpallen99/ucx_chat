defmodule UcxChat.Console do
  @moduledoc """
  Console commands

  ## List
  * ca
  * ftab
  """
  alias UcxChat.ClientAgent, as: CA


  @doc """
  Get ClientAgent state
  """
  def ca, do: CA.get

  @doc """
  Get ftab state for a given client_id, channel_id
  """
  def ftab(client_id, channel_id), do: CA.get_ftab(client_id, channel_id)

end
