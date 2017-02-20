defmodule UcxChat.Channel do
  use UcxChat.Web, :model

  require Logger

  @module __MODULE__

  schema "channels" do
    field :name, :string
    field :topic, :string
    field :type, :integer, default: 0
    field :read_only, :boolean, default: false
    field :archived, :boolean, default: false
    field :description, :string
    has_many :subscriptions, UcxChat.Subscription
    has_many :clients, through: [:subscriptions, :client]
    has_many :stared_messages, UcxChat.StaredMessage
    has_many :messages, UcxChat.Message
    belongs_to :owner, UcxChat.Client, foreign_key: :client_id

    timestamps(type: :utc_datetime)
  end

  @fields ~w(archived name type topic read_only client_id description)a
  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required([:name, :client_id])
    |> validate_format(:name, ~r/^[a-z0-9\.\-_]+$/i)
    |> validate_length(:name, min: 2, max: 25)
  end

  def changeset_settings(struct, [{"private", value}] = params) do
    Logger.warn "changeset #{inspect params}"
    type = if value == "true", do: 1, else: 0
    changeset(struct, %{type: type})
  end
  def changeset_settings(struct, [{field, value}] = params) do
    value = case value do
      "true" -> true
      "false" -> false
      other -> other
    end
    changeset(struct, %{field => value})
  end


  def get_all_channels do
    from c in @module, where: c.type in [0,1]
  end

  def get_all_public_channels do
    from c in @module, where: c.type == 0
  end
end
