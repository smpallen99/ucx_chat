defmodule UcxChat.ChannelClient do
  use UcxChat.Web, :model

  schema "channels_clients" do
    belongs_to :channel, UcxChat.Channel
    belongs_to :client, UcxChat.Client
    field :last_read, :integer
    field :type, :integer
    timestamps()
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

  @fields ~w(channel_id client_id)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields ++ [:last_read, :type])
    |> validate_required(@fields)
  end
end
