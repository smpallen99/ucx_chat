defmodule UcxChat.AccountView do
  use UcxChat.Web, :view

  def allow_delete_own_account, do: true
  def allow_password_change, do: true
  def allow_email_change, do: true
  def email_verified, do: true
  def allow_username_change, do: true

  def desktop_notification_duration, do: true
  def desktop_notification_disabled, do: false
  def desktop_notification_enabled, do: true
  def get_languages do
    [English: "en"]
  end
end
