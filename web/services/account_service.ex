defmodule UcxChat.AccountService do
  alias UcxChat.{Repo, User, Notification, AccountNotification}
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger

  def new_notification(account_id, channel_id) do
    notif =
      channel_id
      |> Notification.new_changeset
      |> Repo.insert!

    notif.id
    |> AccountNotification.new_changeset(account_id)
    |> Repo.insert!

    notif
  end

  def update_notification(notification, params) do
    cs = Notification.changeset(notification, params)
    Logger.warn "cs: #{inspect cs}, params: #{inspect params}"
    Repo.update cs
  end

end
