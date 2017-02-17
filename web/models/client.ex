defmodule UcxChat.Client do
  use UcxChat.Web, :model

  schema "clients" do
    field :nickname, :string
    field :chat_status, :string
    field :tag_line, :string
    field :uri, :string
    has_one :user, UcxChat.User
    has_many :channels_clients, UcxChat.ChannelClient
    has_many :channels, through: [:channels_clients, :channel]
    has_many :stared_messages, UcxChat.StaredMessage
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
