defmodule UcxChat.MessageService do
  import Ecto.Query
  alias UcxChat.{Message, Repo}

  def get_messages(channel_id) do
    Message
    |> where([m], m.channel_id == ^channel_id)
    |> preload([:client])
    # |> join(:left, [m], c in assoc(m, :client))
    # |> select([m,c], {m, c})
    # |> select([m,c], {m.id, m.body, m.updated_at, c.id, c.nickname})
    |> Repo.all
    # |> Enum.map(fn {m, c} ->
    #   struct(m, client: c)
    # end)
  end
  def last_client_id(channel_id) do
    Message
    |> where([m], m.channel_id == ^channel_id)
    |> last
    |> Repo.one
    |> Map.get(:client_id)
  end
end
