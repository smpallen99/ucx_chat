defmodule UcxChat.Message do
  use UcxChat.Web, :model
  require Logger

  schema "messages" do
    field :body, :string
    field :sequential, :boolean, default: false
    field :timestamp, :string
    field :type, :string, default: ""
    field :expire_at, :utc_datetime

    belongs_to :client, UcxChat.Client
    belongs_to :channel, UcxChat.Channel
    belongs_to :edited_by, UcxChat.Client, foreign_key: :edited_id

    has_many :stars, UcxChat.StaredMessage

    field :is_groupable, :boolean, virtual: true
    field :system, :string, virtual: true
    field :t, :string, virtual: true
    field :own, :boolean, virtual: true
    field :is_temp, :boolean, virtual: true
    field :chat_opts, :boolean, virtual: true
    field :custom_class, :string, virtual: true
    field :avatar, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @fields [:body, :client_id, :channel_id, :sequential, :timestamp, :edited_id, :type, :expire_at, :type]
  @required [:body, :client_id]

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

end

