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
    has_many :users, through: [:subscriptions, :user]
    has_many :stared_messages, UcxChat.StaredMessage
    has_many :messages, UcxChat.Message
    belongs_to :owner, UcxChat.User, foreign_key: :user_id

    timestamps(type: :utc_datetime)
  end

  @fields ~w(archived name type topic read_only user_id description)a
  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required([:name, :user_id])
    |> validate_format(:name, ~r/^[a-z0-9\.\-_]+$/i)
    |> validate_length(:name, min: 2, max: 25)
  end

  def changeset_settings(struct, [{"private", value}]) do
    type = if value == true, do: 1, else: 0
    changeset(struct, %{type: type})
  end
  def changeset_settings(struct, [{field, value}]) do
    # value = case value do
    #   "true" -> true
    #   "false" -> false
    #   other -> other
    # end
    changeset(struct, %{field => value})
  end

  def total_rooms do
    from c in @module, select: count(c.id)
  end

  def total_rooms(type) do
    from c in @module, where: c.type == ^type, select: count(c.id)
  end

  def total_channels do
    total_rooms 0
  end

  def total_private do
    total_rooms 1
  end

  def total_direct do
    total_rooms 2
  end

  def get_all_channels do
    from c in @module, where: c.type in [0,1]
  end

  def get_all_public_channels do
    from c in @module, where: c.type == 0
  end
end
