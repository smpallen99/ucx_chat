defmodule UcxChat.Notification do
  use UcxChat.Web, :model
  alias UcxChat.{AccountNotification, User, Account, NotificationSetting}

  @mod __MODULE__

  schema "notifications" do
    embeds_one :settings, UcxChat.NotificationSetting
    belongs_to :channel, UcxChat.Channel
    many_to_many :accounts, UcxChat.Account, join_through: UcxChat.AccountNotification

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:channel_id])
    |> cast_embed(:settings)
    |> validate_required([:settings, :channel_id])
  end

  def new_changeset(channel_id) do
    settings = Map.from_struct %NotificationSetting{}
    changeset %__MODULE__{}, %{channel_id: channel_id, settings: settings}
  end


  def get_notification(%{id: id}, channel_id), do: get_notification(id, channel_id)
  def get_notification(id, channel_id) do
    from n in @mod,
      join: j in AccountNotification,
      on: j.notification_id == n.id,
      where: j.account_id == ^id and n.channel_id == ^channel_id,
      select: n
  end
  # def get_notification_by_user_id(user_id, channel_id) do
  #   from a in Account,
  #     join: u in User, on: u.id == ^user_id,
  #     join: j in AccountNotification, on: j.account_id == a.id,
  #     join: n in @mod, on: n.id == j.notification_id,

  #     select: a
  #   # from u in User,
  #   #   join: a in Account, on: a.user_id == u.id,
  #   #   join: j in AccountNotification, on: j.account_id == a.id,
  #   #   join: n in @mod, on: n.id == j.notification_id,
  #   #   # where: n.channel_id == ^channel_id,
  #   #   select: a
  #   #   # select: n
  # end

end
