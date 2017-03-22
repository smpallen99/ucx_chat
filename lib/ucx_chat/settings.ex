defmodule UcxChat.Settings do
  alias UcxChat.{Notification, Repo}

  [
    general: UcxChat.Config.General,
    message: UcxChat.Config.Message,
    layout: UcxChat.Config.Layout
  ]
  |> Enum.map(fn {field, mod} ->
    Enum.map mod.__schema__(:fields) -- [:id], fn name ->
      def unquote(name)() do
        UcxChat.Settings.config()
        |> Map.get(unquote(field))
        |> Map.get(unquote(name))
      end
      def unquote(name)(config) do
        config
        |> Map.get(unquote(field))
        |> Map.get(unquote(name))
      end
    end
  end)

  def config do
    UcxChat.Repo.one(UcxChat.Config)
  end

  def get_desktop_notification_duration(_user, _channel) do
    desktop_notification_duration()
  end

  def get_new_message_sound(user, channel_id) do
    default = "chime"
    case Notification.get_notification(user.account_id, channel_id) |> Repo.one do
      nil -> default
      %{settings: %{audio: "system_default"}} -> default
      %{settings: %{audio: "none"}} -> nil
      %{settings: %{audio: sound}} -> sound
    end
  end
end
