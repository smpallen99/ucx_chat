defmodule UcxChat.Upload do
  use UcxChat.Web, :model
  use Arc.Ecto.Schema

  schema "upload" do
    field :file, UcxChat.File.Type
    field :name, :string, default: ""
    field :description, :string, default: ""
    field :type, :string, default: ""
    field :size, :integer, default: 0
    belongs_to :channel, UcxChat.Channel
    belongs_to :user, UcxChat.User

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:file, :channel_id, :user_id, :name, :description, :type, :size])
    |> cast_attachments(params, [:file])
    |> validate_required([:file])
  end
end
