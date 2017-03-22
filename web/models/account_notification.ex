defmodule UcxChat.AccountNotification do
  use UcxChat.Web, :model

  schema "accounts_notifications" do
    belongs_to :account, UcxChat.Account
    belongs_to :notification, UcxChat.Notification

    timestamps(type: :utc_datetime)
  end

  @fields ~w(account_id notification_id)a
  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:account_id, name: :accounts_notifications_account_id_notification_id_index)
  end

  def new_changeset(notification_id, account_id) do
    changeset %__MODULE__{}, %{notification_id: notification_id, account_id: account_id}
  end

end
