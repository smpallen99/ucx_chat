defmodule UcxChat.AccountService do
  alias UcxChat.{Repo, Notification, AccountNotification, Account}
  # alias UcxChat.ServiceHelpers, as: Helpers

  # require Logger

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
    notification
    |> Notification.changeset(params)
    |> Repo.update
  end

  def update_emoji_recent(account, name) do
    unless has_emoji_recent? account, name do
      recent =
        case account.emoji_recent do
          "" -> name
          recent -> recent <> " " <> name
        end
      account
      |> Account.changeset(%{emoji_recent: recent})
      |> Repo.update
    end
  end

  def has_emoji_recent?(account, name) do
    Regex.match? ~r/(\s|^)#{name}(\s|$)/, account.emoji_recent
  end

  def emoji_recents(account) do
    String.split account.emoji_recent, " ", trim: true
  end

end
