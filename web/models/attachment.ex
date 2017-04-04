defmodule UcxChat.Attachment do
  use UcxChat.Web, :model
  use Arc.Ecto.Schema
  alias __MODULE__

  schema "attachments" do
    field :file, UcxChat.File.Type
    field :file_name, :string, default: ""
    field :description, :string, default: ""
    field :type, :string, default: ""
    field :size, :integer, default: 0
    belongs_to :channel, UcxChat.Channel
    belongs_to :message, UcxChat.Message

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:channel_id, :message_id, :file_name, :description, :type, :size])
    |> cast_attachments(params, [:file])
    |> validate_required([:file, :channel_id, :message_id])
  end

end
