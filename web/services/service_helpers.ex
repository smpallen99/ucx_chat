defmodule UcxChat.ServiceHelpers do
  alias UcxChat.{Repo, FlexBarView, Channel, Client, ChannelClient}

  import Ecto.Query

  def get(model, id, opts \\ []) do
    preload = opts[:preload] || []
    model
    |> where([c], c.id == ^id)
    |> preload(^preload)
    |> Repo.one!
  end

  def get_by(model, field, value, opts \\ []) do
    preload = opts[:preload] || []
    model
    |> where([c], field(c, ^field) == ^value)
    |> preload(^preload)
    |> Repo.one!
  end

  def get_channel(channel_id, preload \\ []) do
    Channel
    |> where([c], c.id == ^channel_id)
    |> preload(^preload)
    |> Repo.one!
  end

  def get_client(client_id, opts \\ []) do
    preload = opts[:preload] || []
    Client
    |> where([c], c.id == ^client_id)
    |> preload(^preload)
    |> Repo.one!
  end

  def get_channel_client(channel_id, client_id, opts \\ []) do
    preload = opts[:preload] || []

    ChannelClient
    |> where([c], c.client_id == ^client_id and c.channel_id == ^channel_id)
    |> preload(^preload)
    |> Repo.one!
  end

  def get_client_by_name(nickname, preload \\ [])
  def get_client_by_name(nil, _), do: nil
  def get_client_by_name(nickname, preload) do
    Client
    |> where([c], c.nickname == ^nickname)
    |> preload(^preload)
    |> Repo.one!
  end

end
