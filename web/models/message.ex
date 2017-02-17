defmodule UcxChat.Message do
  use UcxChat.Web, :model
  require Logger

  schema "messages" do
    field :body, :string
    field :sequential, :boolean, default: false
    field :timestamp, :string

    has_many :stars, UcxChat.StaredMessage

    belongs_to :client, UcxChat.Client
    belongs_to :channel, UcxChat.Channel

    field :is_groupable, :boolean, virtual: true
    field :system, :string, virtual: true
    field :t, :string, virtual: true
    field :own, :boolean, virtual: true
    field :is_temp, :boolean, virtual: true
    field :chat_opts, :boolean, virtual: true
    field :custom_class, :string, virtual: true
    field :avatar, :string, virtual: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :client_id, :channel_id, :sequential, :timestamp])
    |> validate_required([:body, :client_id])
    |> add_timestamp
  end

  def add_timestamp(%{data: %{timestamp: nil}} = changeset) do
    # Logger.warn "changeset: #{inspect changeset}, timestamp: #{inspect changeset.data.timestamp}"
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

  # def format_date(%NaiveDateTime{} = dt) do
  #   {{yr, mo, day}, _} = NaiveDateTime.to_erl(dt)
  #   month(mo) <> " " <> to_string(day) <> ", " <> to_string(yr)
  # end

  # def format_time(%NaiveDateTime{} = dt) do
  #   {_, {hr, min, _sec}} = NaiveDateTime.to_erl(dt)
  #   min = to_string(min) |> String.pad_leading(2, "0")
  #   {hr, meridan} =
  #     case hr do
  #       hr when hr < 12 -> {hr, " AM"}
  #       hr when hr == 12 -> {hr, " PM"}
  #       hr -> {hr - 12, " PM"}
  #     end
  #   to_string(hr) <> ":" <> min <> meridan
  # end

  # def format_date_time(%NaiveDateTime{} = dt) do
  #   format_date(dt) <> " " <> format_time(dt)
  # end

  # def month(1), do: "January"
  # def month(2), do: "February"
  # def month(3), do: "March"
  # def month(4), do: "April"
  # def month(5), do: "May"
  # def month(6), do: "June"
  # def month(7), do: "July"
  # def month(8), do: "August"
  # def month(9), do: "September"
  # def month(10), do: "October"
  # def month(11), do: "November"
  # def month(12), do: "December"

end

