defmodule UcxChat.Mention do
  use UcxChat.Web, :model

  schema "mentions" do
    field :unread, :boolean, default: true

    belongs_to :client, UcxChat.Client
    belongs_to :message, UcxChat.Message
    belongs_to :channel, UcxChat.Channel

    timestamps(type: :utc_datetime)
  end

  @fields ~w(client_id message_id channel_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields ++ [:unread])
    |> validate_required(@fields)
  end
end
