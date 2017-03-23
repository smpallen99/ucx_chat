defmodule UcxChat.NotifierService do
  use UcxChat.Web, :service
  use UcxChat.Gettext

  require Logger

  alias UcxChat.{MessageService}

  def notify_action(socket, action, channel, user) do
    do_notifier_action(socket, action, user, channel)
  end

  defp do_notifier_action(_socket, :archive, owner, channel) do
    body = ~g"This room has been archived by " <> owner.username
    MessageService.broadcast_system_message(channel.id, owner.id, body)
  end
  defp do_notifier_action(_socket, :unarchive, owner, channel) do
    body = ~g"This room has been unarchived by " <> owner.username
    MessageService.broadcast_system_message(channel.id, owner.id, body)
  end
  defp do_notifier_action(_socket, action, _owner, channel) do
    Logger.warn "unsupported action: #{inspect action}, channel.id: #{inspect channel.id}, channel.name: #{inspect channel.name}"
  end

end
