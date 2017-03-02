defmodule UcxChat.Console do
  @moduledoc """
  Console commands

  ## List
  * ca
  * ftab
  """
  alias UcxChat.UserAgent, as: CA


  @doc """
  Get UserAgent state
  """
  def ca, do: CA.get

  @doc """
  Get ftab state for a given user_id, channel_id
  """
  def ftab(user_id, channel_id), do: CA.get_ftab(user_id, channel_id)

end
