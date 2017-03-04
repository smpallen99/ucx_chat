defmodule UcxChat.Message do
  use UcxChat.Web, :model
  use UcxChat.Utils
  require Logger

  @mod __MODULE__

  schema "messages" do
    field :body, :string
    field :sequential, :boolean, default: false
    field :timestamp, :string
    field :type, :string, default: ""
    field :expire_at, :utc_datetime
    field :system, :boolean, default: false

    belongs_to :user, UcxChat.User
    belongs_to :channel, UcxChat.Channel
    belongs_to :edited_by, UcxChat.User, foreign_key: :edited_id

    has_many :stars, UcxChat.StaredMessage

    field :is_groupable, :boolean, virtual: true
    field :t, :string, virtual: true
    field :own, :boolean, virtual: true
    field :is_temp, :boolean, virtual: true
    field :chat_opts, :boolean, virtual: true
    field :custom_class, :string, virtual: true
    field :avatar, :string, virtual: true
    field :new_day, :boolean, default: false, virtual: true  # new_day

    timestamps(type: :utc_datetime)
  end

  @fields [:body, :user_id, :channel_id, :sequential, :timestamp, :edited_id, :type, :expire_at, :type, :system]
  @required [:body, :user_id]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required)
    |> add_timestamp
  end

  def add_timestamp(%{data: %{timestamp: nil}} = changeset) do
    put_change(changeset, :timestamp, UcxChat.ServiceHelpers.get_timestamp())
  end
  def add_timestamp(changeset) do
    changeset
  end

  def format_timestamp(%NaiveDateTime{} = dt) do
    {{yr, mo, day}, {hr, min, sec}} = NaiveDateTime.to_erl(dt)
    pad2(yr) <> pad2(mo) <> pad2(day) <> pad2(hr) <> pad2(min) <> pad2(sec)
  end

  def pad2(int), do: int |> to_string |> String.pad_leading(2, "0")

  def total_count do
    from m in @mod, select: count(m.id)
  end

  def total_channels(type \\ 0) do
    from m in @mod,
      join: c in UcxChat.Channel, on: m.channel_id == c.id,
      where: c.type == ^type,
      select: count(m.id)
  end

  def total_private do
    total_channels 1
  end

  def total_direct do
    total_channels 2
  end

end

