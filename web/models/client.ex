defmodule UcxChat.Client do
  use UcxChat.Web, :model

  schema "chat_clients" do
    field :nickname, :string
    field :chat_status, :string
    field :tag_line, :string
    field :uri, :string
    has_one :user, UcxChat.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:nickname, :chat_status, :tag_line, :uri])
    |> validate_required([:nickname])
  end
end
