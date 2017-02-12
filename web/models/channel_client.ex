defmodule UcxChat.ChannelClient do
  use UcxChat.Web, :model

  schema "channels_clients" do
    belongs_to :channel, UcxChat.Channel
    belongs_to :client, UcxChat.Client
    timestamps()
  end

  @fields ~w(channel_id client_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
