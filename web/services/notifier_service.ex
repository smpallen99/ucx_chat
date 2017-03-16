defmodule UcxChat.NotifierService do
  use UcxChat.Web, :service
  use UcxChat.Gettext

  require Logger

  alias UcxChat.{User, MessageService}

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

  # def notify_action(socket, action, target_name, %User{} = owner, channel_id) do
  #   do_notifier_action(socket, action, owner, target_name, channel_id)
  #   socket
  # end
  # def notify_action(socket, action, target_name, owner_id, channel_id) when is_integer(owner_id) do
  #   notify_action(socket, action, target_name, Helpers.get(User, owner_id), channel_id)
  # end

  # defp do_notifier_action(socket, :archive, owner, _target_name, channel_id) do
  #   body = ~g"This room has been archived by " <> owner.username
  #   MessageService.broadcast_system_message(channel_id, owner.id, body)
  # end
  # defp do_notifier_action(socket, :unarchive, owner, _target_name, channel_id) do
  #   body = ~g"This room has been unarchived by " <> owner.username
  #   MessageService.broadcast_system_message(channel_id, owner.id, body)
  # end
  # defp do_notifier_action(_, _, _, _, _), do: nil

  # defp broadcast_message(socket, body, user_id, channel_id, opts \\ []) do
  #   {message, html} = MessageService.create_and_render(body, user_id, channel_id, opts)
  #   MessageService.broadcast_message(socket, message.id, user_id, html)
  # end
  # def notify_user_action2(socket, user, user_id, channel_id, fun) do
  #   owner = Helpers.get(User, user_id)
  #   body = fun.(user.username, owner.username)
  #   broadcast_message2(socket, body, user_id, channel_id, system: true)
  # end

end
