defmodule UcxChat.Reaction do
  use UcxChat.Web, :model

  schema "reactions" do
    field :emoji, :string
    field :user_ids, :string
    field :count, :integer, default: 1
    belongs_to :message, UcxChat.Message

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:emoji, :user_ids, :message_id, :count])
    |> validate_required([:emoji, :count, :message_id])
  end
end
