defmodule UcxChat.Channel do
  use UcxChat.Web, :model

  alias UcxChat.{Repo, Permission, Subscription, User}

  require Logger

  @module __MODULE__

  schema "channels" do
    field :name, :string
    field :topic, :string
    field :type, :integer, default: 0
    field :read_only, :boolean, default: false
    field :archived, :boolean, default: false
    field :blocked, :boolean, default: false
    field :default, :boolean, default: false
    field :description, :string
    has_many :subscriptions, UcxChat.Subscription, on_delete: :delete_all
    has_many :users, through: [:subscriptions, :user], on_delete: :nilify_all
    has_many :stared_messages, UcxChat.StaredMessage
    has_many :messages, UcxChat.Message
    has_many :notifications, UcxChat.Notification

    belongs_to :owner, UcxChat.User, foreign_key: :user_id

    timestamps(type: :utc_datetime)
  end

  @fields ~w(archived name type topic read_only blocked default user_id description)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def do_changeset(struct, user, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_permission(user)
    |> validate_required([:name, :user_id])
    |> validate_format(:name, ~r/^[a-z0-9\.\-_]+$/i)
    |> validate_length(:name, min: 2, max: 50)
  end

  def changeset_settings(struct, user, [{"private", value}]) do
    type = if value == true, do: 1, else: 0
    do_changeset(struct, user, %{type: type})
  end
  def changeset_settings(struct, user, [{field, value}]) do
    do_changeset(struct, user, %{field => value})
  end

  def changeset_delete(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
  end

  def blocked_changeset(struct, blocked) when blocked in [true, false] do
    struct
    |> cast(%{blocked: blocked}, @fields)
    |> validate_required([:name, :user_id])
    |> validate_format(:name, ~r/^[a-z0-9\.\-_]+$/i)
    |> validate_length(:name, min: 2, max: 25)
  end

  def validate_permission(%{changes: changes, data: data} = changeset, user) do
    # Logger.warn "validate_permission: changeset: #{inspect changeset}, type: #{inspect changeset.data.type}"
    cond do
      changes[:type] != nil -> has_permission?(user, changes)
      true -> has_permission?(user, data)
    end
    |> case do
      true -> changeset
      _ ->
        add_error(changeset, :user, "permission denied")
    end
  end

  defp has_permission?(user, %{type: 1}), do: Permission.has_permission?(user, "create-p")
  defp has_permission?(user, %{type: 2}), do: Permission.has_permission?(user, "create-d")
  defp has_permission?(user, _), do: Permission.has_permission?(user, "create-c")

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

  def get_authorized_channels(user_id) do
    user = UcxChat.ServiceHelpers.get_user!(user_id)
    cond do
      User.has_role?(user, "admin") ->
        from c in @module, where: c.type == 0 or c.type == 1
      User.has_role?(user, "user") ->
        from c in @module,
          left_join: s in Subscription, on: s.channel_id == c.id and s.user_id == ^user_id,
          where: (c.type == 0 or (c.type == 1 and not is_nil(s.id))) and (not s.hidden or c.user_id == ^user_id)
      true -> from c in @module, where: false
    end
  end


  # all puplic and
  # privates that I'm subscribed too
  # and all channels I own
  def get_all_channels(%User{id: user_id} = user) do
    cond do
      User.has_role?(user, "admin") ->
        from c in @module, where: c.type == 0 or c.type == 1, preload: [:subscriptions]
      User.has_role?(user, "user") ->
        from c in @module,
          left_join: s in Subscription, on: s.channel_id == c.id and s.user_id == ^user_id,
          where: c.type == 0 or (c.type == 1 and s.user_id == ^user_id) or c.user_id == ^user_id
      true -> from c in @module, where: false
    end
  end

  def get_all_channels(user_id) do
    user_id
    |> UcxChat.ServiceHelpers.get_user!
    |> get_all_channels
  end

  def room_route(channel) do
    case channel.type do
      ch when ch in [0,1] -> "channels"
      _ -> "direct"
    end
  end

  def direct?(channel) do
    channel.type == 2
  end

  def subscription_status(%{subscriptions: subs} = _channel, user_id) when is_list(subs) do
    Enum.reduce subs, {false, false}, fn
      %{user_id: ^user_id, hidden: hidden}, _acc -> {true, hidden}
      _, acc -> acc
    end
  end
  def subscription_status(channel, user_id) do
    channel
    |> Repo.preload([:subscriptions])
    |> subscription_status(user_id)
  end
end
