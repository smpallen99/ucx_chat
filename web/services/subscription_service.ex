defmodule UcxChat.SubscriptionService do
  use UcxChat.Web, :service

  alias UcxChat.{Subscription}

  def update(%{channel_id: channel_id, user_id: user_id}, params),
    do: __MODULE__.update(channel_id, user_id, params)

  def update(channel_id, user_id, params) do
    case get(channel_id, user_id) do
      nil ->
        {:error, :not_found}
      sub ->
        sub
        |> Subscription.changeset(params)
        |> Repo.update
    end
  end

  def get(channel_id, user_id) do
    channel_id
    |> Subscription.get(user_id)
    |> Repo.one
  end

  def get(channel_id, user_id, field) do
    channel_id
    |> Subscription.get(user_id)
    |> Repo.one
    |> case do
      nil ->
        :error
      sub ->
        Map.get sub, field
    end
  end
end
