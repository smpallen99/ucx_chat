defmodule UcxChat.Mention do
  use UcxChat.Web, :model

  @mod __MODULE__

  schema "mentions" do
    field :unread, :boolean, default: true
    field :all, :boolean, default: false
    field :name, :string

    belongs_to :user, UcxChat.User
    belongs_to :message, UcxChat.Message
    belongs_to :channel, UcxChat.Channel

    timestamps(type: :utc_datetime)
  end

  @fields ~w(user_id message_id channel_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields ++ [:unread, :all, :name])
    |> validate_required(@fields)
  end

  def count(channel_id, user_id) do
    from m in @mod,
      where: m.user_id == ^user_id and m.channel_id == ^channel_id,
      select: count(m.id)
  end
end
