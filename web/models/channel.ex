defmodule UcxChat.Channel do
  use UcxChat.Web, :model

  alias UcxChat.Permission

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
  def do_changeset(struct, user, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_permission(user)
    |> validate_required([:name, :user_id])
    |> validate_format(:name, ~r/^[a-z0-9\.\-_]+$/i)
    |> validate_length(:name, min: 2, max: 25)
  end

  def changeset_settings(struct, user, [{"private", value}]) do
    type = if value == true, do: 1, else: 0
    do_changeset(struct, user, %{type: type})
  end
  def changeset_settings(struct, user, [{field, value}]) do
    # value = case value do
    #   "true" -> true
    #   "false" -> false
    #   other -> other
    # end
    do_changeset(struct, user, %{field => value})
  end

  def validate_permission(%{changes: changes, data: data} = changeset, user) do
    Logger.warn "validate_permission: changeset: #{inspect changeset}, type: #{inspect changeset.data.type}"
    changeset
    cond do
      changes[:type] != nil -> has_permission?(user, changes)
      true -> has_permission?(user, data)
    end
    |> case do
      true -> changeset
      _ ->
        add_error(changeset, :user, "permission denied")
    end
    # if has_permission(user, params) do
    #   {:ok, multi}
    # else
    #   error(multi, :user_id, "You don't have permission for this operation")
    # end
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
end
