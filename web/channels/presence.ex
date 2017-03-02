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
  #     preload: [:user],
  #     select: {u.id, u}

  #   users = query |> Repo.all |> Enum.into(%{})
  #   # Logger.warn "fetch users: #{inspect users}"
  #   for {key, %{metas: metas}} <- entries, into: %{} do
  #     username = case users[String.to_integer(key)] do
  #       nil -> ""
  #       user -> user.username
  #     end
  #     # Logger.warn ".... username: #{inspect username}"
  #     {key, %{metas: metas, username: username}}
  #   end
  # end

end
