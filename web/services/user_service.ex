defmodule UcxChat.UserService do
  use UcxChat.Web, :service
  # alias UcxChat.ServiceHelpers, as: Helpers
  alias UcxChat.{Repo, User, Account, Subscription, Channel, UserRole}
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

  def open_channel_count(user_id) when is_binary(user_id) do
    Repo.one from s in Subscription,
      where: s.open == true and s.user_id == ^user_id,
      select: count(s.id)
  end

  def open_channels(user_id) when is_binary(user_id) do
    Repo.all from s in Subscription,
      join: c in Channel, on: s.channel_id == c.id,
      where: s.open == true and s.user_id == ^user_id,
      select: c
  end

  def delete_user(user) do
    Account
    |> Repo.get(user.account_id)
    |> Account.changeset
    |> Repo.delete
  end

  def deactivate_user(user) do
    (from s in Subscription,
      join: c in Channel, on: s.channel_id == c.id,
      where: c.type == 2 and s.user_id == ^(user.id),
      select: c)
    |> Repo.all
    |> Enum.each(fn channel ->
      Repo.update Channel.changeset_update(channel, %{active: false})
    end)
    user
  end

  def activate_user(user) do
    (from s in Subscription,
      join: c in Channel, on: s.channel_id == c.id,
      where: c.type == 2 and s.user_id == ^(user.id),
      select: c)
    |> Repo.all
    |> Enum.each(fn channel ->
      Repo.update Channel.changeset_update(channel, %{active: true})
    end)
    user
  end

  def insert_user(params, opts \\ []) do
    multi =
      Multi.new
      |> Multi.insert(:account, Account.changeset(%Account{}, %{}))
      |> Multi.run(:user, &do_insert_user(&1, params, opts))
    Repo.transaction(multi)
  end

  defp do_insert_user(%{account: %{id: id}}, params, opts) do
    changeset = User.changeset(%User{}, Map.put(params, "account_id", id))
    case Repo.insert changeset do
      {:ok, user} ->
        %UserRole{}
        |> UserRole.changeset(%{user_id: user.id, role: "user"})
        |> Repo.insert!

        unless opts[:join_default_channels] == false do
          (from c in Channel, where: c.default == true)
          |> Repo.all
          |> Enum.each(fn ch ->
            %Subscription{}
            |> Subscription.changeset(%{channel_id: ch.id, user_id: user.id})
            |> Repo.insert!
          end)
        end
        {:ok, user}
      error ->
        error
    end
  end
end
