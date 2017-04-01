defmodule UcxChat.Settings do
  alias UcxChat.{Notification, Repo}

  [
    general: UcxChat.Config.General,
    message: UcxChat.Config.Message,
    layout: UcxChat.Config.Layout,
    file_upload: UcxChat.Config.FileUpload
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

  def get_desktop_notification_duration(user, channel) do
    cond do
      not enable_desktop_notifications() ->
        nil
      not user.account.enable_desktop_notifications ->
        nil
      not is_nil(user.account.desktop_notification_duration) ->
        user.account.desktop_notification_duration
      true ->
        case Notification.get_notification(user.account_id, channel.id) |> Repo.one do
          nil ->
            desktop_notification_duration()
          %{settings: %{duration: nil}} ->
            desktop_notification_duration()
          %{settings: %{duration: duration}} ->
            duration
        end
    end
  end

  def get_new_message_sound(user, channel_id) do
    default = "chime"
    cond do
      user.account.new_message_notification == "none" ->
        nil
      user.account.new_message_notification != "system_default" ->
        user.account.new_message_notification
      true ->
        case Notification.get_notification(user.account_id, channel_id) |> Repo.one do
          nil -> default
          %{settings: %{audio: "system_default"}} -> default
          %{settings: %{audio: "none"}} -> nil
          %{settings: %{audio: sound}} -> sound
        end
    end
  end
end
