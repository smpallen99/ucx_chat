defmodule UcxChat.MasterView do
  use UcxChat.Web, :view
  alias UcxChat.{ChannelService, Client, Channel, ChatDat}
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
  def view_mode, do: ""

  def has_more_next(text) do
    # {{#unless hasMoreNext}}not{{/unless}}">
    to_string(text)
    |> String.replace("_", "-")
  end
  def has_more(), do: false
  def can_preview, do: true
  def hide_username, do: ""
  def hide_avatar, do: ""

  def is_loading, do: false
  def get_loading, do: ""
  def has_more_next, do: false

  def loading, do: ""
  def get_mb, do: UcxChat.MessageView.get_mb

  def get_open_ftab(nil, _), do: nil
  def get_open_ftab({title, _}, flex_tabs), do: Enum.find(flex_tabs, fn tab -> tab[:open] && tab[:title] == title end)


  def get_flex_tabs(open_tab) do
    defn = UcxChat.FlexBarService.default_settings()
    tab = case open_tab do
      {title, _} -> %{title => true}
      _ -> %{}
    end
    [
      {"Info", "info-circled", ""},
      {"Search", "search", ""},
      {"User Info", "user", ""},
      {"Members List", "users", ""},
      {"Notifications", "bell-alt", ""},
      {"Files List", "attach", ""},
      {"Mentions", "at", ""},
      {"Stared Messages", "star", ""},
      {"Knowledge Base", "lightbulb", " hidden"},
      {"Pinned Messages", "pin", ""},
      {"Past Chats", "chat", " hidden"},
      {"OTR", "key", " hidden"},
      {"Video Chat", "videocam", " hidden"},
      {"Snippeted Messages", "code", ""},
      {"Logout", "logout", ""},
      {"Switch User", "login", ""},
    ]
    |> Enum.map(fn {title, icon, display} ->
      if tab[title] do
        titlea = String.to_atom title
        %{title: title, icon: icon, display: display, open: true, templ: defn[titlea][:templ] }
      else
        %{title: title, icon: icon, display: display}
      end
    end)
  end

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
  def favorite_room?(%Client{} = client, %Channel{} = channel) do
    ChannelService.favorite_room?(client, channel)
  end
end
