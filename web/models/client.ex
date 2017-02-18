defmodule UcxChat.Client do
  use UcxChat.Web, :model

  schema "clients" do
    field :nickname, :string
    field :chat_status, :string
    field :tag_line, :string
    field :uri, :string
    has_one :user, UcxChat.User
    has_many :subscriptions, UcxChat.Subscription
    has_many :channels, through: [:subscriptions, :channel]
    has_many :messages, UcxChat.Message
    has_many :stared_messages, UcxChat.StaredMessage
    timestamps(type: :utc_datetime)
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
