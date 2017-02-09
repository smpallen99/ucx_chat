defmodule UcxChat.Message do
  use UcxChat.Web, :model

  schema "messages" do
    field :body, :string
    belongs_to :client, UcxChat.Client
    belongs_to :channel, UcxChat.ChatChannel

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :client_id, :channel_id])
    |> validate_required([:body, :client_id])
  end
end
