defmodule UcxChat.Subscription do
  use UcxChat.Web, :model

  @module __MODULE__

  schema "subscriptions" do
    belongs_to :channel, UcxChat.Channel
    belongs_to :user, UcxChat.User
    field :last_read, :integer
    field :type, :integer
    field :open, :boolean, default: false
    field :alert, :boolean, default: false
    field :ls, :utc_datetime
    field :f, :boolean, default: false          # favorite
    field :unread, :integer, default: 0
    timestamps(type: :utc_datetime)
  end

  # message -> room
  # room can be channel(public or private), dm(private), favorite, group(private)
  # favorite is just a name
  # could message polymorphic room_type, room_id
  # when a message comes in, the room_type and id are presented, but then we can search on them,
  # dm is between two or more people
  # can have a separate mapping table associated for a user that points to the room table
  # room join table will have an entry for 'Steve Merilee' will all the messages
  # dm table maps Steve, room table id, and an entry that maps Merilee to the same join table
  # so, when steve is logged in and fetches /direct/Merilee, we look in dm table for steve, merilee and get get the
  # entry where the messages are stored.
  # room => name: string, room_type: String, room_id: integer

  @fields ~w(channel_id user_id)a
  @all_fields @fields ++ ~w(last_read type open alert ls f unread)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all_fields)
    |> validate_required(@fields)
    |> unique_constraint(:user_id, name: :subscriptions_user_id_channel_id_index)
  end

  def get_all_for_channel(channel_id) do
    from c in @module, where: c.channel_id == ^channel_id
  end

  def get(channel_id, user_id) do
    from c in @module, where: c.channel_id == ^channel_id and c.user_id == ^user_id
  end
end
