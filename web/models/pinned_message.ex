defmodule UcxChat.PinnedMessage do
  use UcxChat.Web, :model

  schema "pinned_messages" do
    belongs_to :message, UcxChat.Message
    belongs_to :channel, UcxChat.Channel

    timestamps(type: :utc_datetime)
  end

  @fields ~w(message_id channel_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end
end
