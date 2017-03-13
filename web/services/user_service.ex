defmodule UcxChat.UserService do
  # alias UcxChat.ServiceHelpers, as: Helpers
  alias UcxChat.{Repo, User}

  def total_users_count do
    User.total_count() |> Repo.one
  end

  def online_users_count do
    Coherence.CredentialStore.Agent
    |> Agent.get(&(&1))
    |> Map.keys
    |> length
  end

  def get_online_users do
    Coherence.CredentialStore.Agent
    |> Agent.get(&(&1))
    |> Map.values
  end

  def get_all_users do
    User.all() |> Repo.all
  end

end
