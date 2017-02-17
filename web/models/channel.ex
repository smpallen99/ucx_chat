defmodule UcxChat.Channel do
  use UcxChat.Web, :model

  schema "channels" do
    field :name, :string
    field :topic, :string
    field :type, :integer, default: 0
    field :read_only, :boolean, default: false
    has_many :channels_clients, UcxChat.ChannelClient
    has_many :clients, through: [:channels_clients, :client]
    has_many :stared_messages, UcxChat.StaredMessage

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :type, :topic, :read_only])
    |> validate_required([:name])
  end
end
