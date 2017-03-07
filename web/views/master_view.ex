defmodule UcxChat.MasterView do
  use UcxChat.Web, :view
  alias UcxChat.{ChannelService, User, Channel, ChatDat}
  require IEx

  def get_admin_class(_user), do: ""
  def get_window_id(channel), do: "chat-window-#{channel.id}"

  def embedded_version, do: false
  def unread, do: false
  def show_toggle_favorite, do: true
  def get_user_status(_), do: "offline"

  def container_bars_show(_channel) do
    # %div(class="container-bars #{container_bars_show unreadData uploading}}">
    "show"
  end
  # def get_unread_data(_), do: false
  def get_unread_data(_) do
    count_span = content_tag :span, class: "unread-cnt" do
      "0"
    end
    %{count: " new messages", since: " new messages since 11:08 AM", count_span: count_span}
    # %{count: "78 new messages", since: "78 new messages since 11:08 AM"}
  end

  def get_uploading(_conn), do: []
  def has_upload_error(_conn) do
    # "error-background error-border"
    ""
  end
  def get_upload_error(_conn) do
    false
  end
  def get_error_percentage(_error), do: 100
  def get_error_name(_error), do: ""
  def message_box_selectable do
    # "selectable"
    ""
  end
  def view_mode(user) do
    case user.account.view_mode do
      1 -> ""
      2 -> " cozy"
      3 -> " compact"
      _ -> ""
    end
  end

  def has_more_next(text) do
    # {{#unless hasMoreNext}}not{{/unless}}">
    to_string(text)
    |> String.replace("_", "-")
  end
  def has_more(), do: false
  def can_preview, do: true

  def hide_avatar(user) do
    if user.account.hide_avatars, do: " hide-avatars", else: ""
  end
  def hide_username(user) do
    if user.account.hide_user_names, do: " hide-usernames", else: ""
  end

  def is_loading, do: false
  def get_loading, do: ""
  def has_more_next, do: false

  def loading, do: ""
  def get_mb(chatd), do: UcxChat.MessageView.get_mb(chatd)

  def get_open_ftab(nil, _), do: nil
  def get_open_ftab({title, _}, flex_tabs), do: Enum.find(flex_tabs, fn tab -> tab[:open] && tab[:title] == title end)

  def cc(config, item) do
    if apply UcxChat.Settings, item, [config] do
      ""
    else
      " hidden"
    end
  end

  def uu(true, "User Info"), do: ""
  def uu(false, "Members List"), do: ""
  def uu(_, _), do: " hidden"

  def get_flex_tabs(chatd, open_tab) do
    user = chatd.user
    user_mode = chatd.channel.type == 2
    Logger.warn "chatd: #{inspect chatd}"
    switch_user = if Application.get_env :ucx_chat, :switch_user, false do
      ""
    else
      " hidden"
    end
    config = Settings.config
    defn = UcxChat.FlexBarService.default_settings()
    tab = case open_tab do
      {title, _} -> %{title => true}
      _ -> %{}
    end
    [
      {"IM Mode", "chat", ""},
      {"Rooms Mode", "hash", " hidden"},
      {"Info", "info-circled", ""},
      {"Search", "search", ""},
      {"User Info", "user", uu(user_mode, "User Info")},
      {"Members List", "users", uu(user_mode, "Members List")},
      {"Notifications", "bell-alt", " hidden"},
      {"Files List", "attach", " hidden"},
      {"Mentions", "at", ""},
      {"Stared Messages", "star", cc(config, :allow_message_staring)},
      {"Knowledge Base", "lightbulb", " hidden"},
      {"Pinned Messages", "pin", cc(config, :allow_message_pinning)},
      {"Past Chats", "chat", " hidden"},
      {"OTR", "key", " hidden"},
      {"Video Chat", "videocam", " hidden"},
      {"Snippeted Messages", "code", cc(config, :allow_message_snippeting)},
      {"Switch User", "login", switch_user},
      {"Logout", "logout", " hidden"},
    ]
    |> Enum.map(fn {title, icon, display} ->
      if tab[title] do
        titlea = String.to_atom title
        %{title: title, icon: icon, display: display, open: true, templ: defn[titlea][:templ] }
      else
        display = check_im_mode_display(title, user.account.chat_mode, display)
        %{title: title, icon: icon, display: display}
      end
    end)
  end

  defp check_im_mode_display("IM Mode", true, _), do: " hidden"
  defp check_im_mode_display("IM Mode", _, _), do: ""
  defp check_im_mode_display("Rooms Mode", false, _), do: " hidden"
  defp check_im_mode_display("Rooms Mode", _, _), do: ""
  defp check_im_mode_display("Members List", true, _), do: " hidden"
  defp check_im_mode_display("Pinned Messages", true, _), do: " hidden"
  defp check_im_mode_display("Info", true, _), do: " hidden"
  defp check_im_mode_display(_, _, display), do: display

  def get_fav_icon(chatd) do
    case ChatDat.get_channel_data(chatd) do
      %{type: :stared} -> "icon-star-empty"
      _ -> "icon-star-empty"
    end
  end
  def get_fav_icon_label(chatd) do

    case ChatDat.get_channel_data(chatd) do
      %{type: :stared} ->
        {"icon-star favorite-room pending-color", "Unfavorite"}
      _other ->
        {"icon-star-empty", "Favorite"}
    end
  end
  def favorite_room?(%User{} = user, %Channel{} = channel) do
    ChannelService.favorite_room?(user, channel)
  end

  def direct?(chatd) do
    chatd.channel.type == 2
  end
end
