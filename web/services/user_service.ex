defmodule UcxChat.UserService do
  # alias UcxChat.ServiceHelpers, as: Helpers
  alias UcxChat.{Repo, User, Account}
  alias Ecto.Multi

  require Logger

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

  def delete_user(user) do
    Account
    |> Repo.get(user.account_id)
    |> Account.changeset
    |> Repo.delete
  end

  def insert_user(params) do
    multi =
      Multi.new
      |> Multi.insert(:account, Account.changeset(%Account{}, %{}))
      |> Multi.run(:user, &do_insert_user(&1, params))
    Repo.transaction(multi)
  end

  defp do_insert_user(%{account: %{id: id}}, params) do
    changeset = User.changeset(%User{}, Map.put(params, "account_id", id))
    Repo.insert changeset
  end
end
