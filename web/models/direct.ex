defmodule UcxChat.Direct do
  use UcxChat.Web, :model

  schema "directs" do
    field :clients, :string
    belongs_to :client, UcxChat.Client
    belongs_to :channel, UcxChat.Channel

    timestamps()
  end

  @fields ~w(clients client_id channel_id)a
  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:clients, name: :directs_client_id_users_index)
  end
end
