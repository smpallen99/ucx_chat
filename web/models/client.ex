defmodule UcxChat.Client do
  use UcxChat.Web, :model

  schema "clients" do
    field :nickname, :string
    field :chat_status, :string
    field :tag_line, :string
    field :uri, :string
    field :status, :string, default: "offline", virtual: true
    belongs_to :open, UcxChat.Channel, foreign_key: :open_id
    has_one :user, UcxChat.User
    has_many :subscriptions, UcxChat.Subscription
    has_many :channels, through: [:subscriptions, :channel]
    has_many :messages, UcxChat.Message
    has_many :stared_messages, UcxChat.StaredMessage
    has_many :owns, UcxChat.Channel, foreign_key: :client_id

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:nickname, :chat_status, :tag_line, :uri, :open_id])
    |> validate_required([:nickname])
  end
end
