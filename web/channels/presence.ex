defmodule UcxChat.Presence do
  use Phoenix.Presence, otp_app: :ucx_chat,
                        pubsub_server: UcxChat.PubSub
  # require Logger
  # import Ecto.Query
  # alias UcxChat.{User, Repo}

  # def fetch(_topic, entries) do
  #   keys =
  #     entries
  #     |> Map.keys
  #     |> Enum.map(&String.to_integer/1)
  #   query =
  #     from u in User,
  #     where: u.id in ^keys,
  #     preload: [:client],
  #     select: {u.id, u}

  #   users = query |> Repo.all |> Enum.into(%{})
  #   # Logger.warn "fetch users: #{inspect users}"
  #   for {key, %{metas: metas}} <- entries, into: %{} do
  #     nickname = case users[String.to_integer(key)] do
  #       nil -> ""
  #       user -> user.client.nickname
  #     end
  #     # Logger.warn ".... nickname: #{inspect nickname}"
  #     {key, %{metas: metas, nickname: nickname}}
  #   end
  # end

end
