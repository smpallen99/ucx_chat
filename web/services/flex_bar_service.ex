defmodule UcxChat.FlexBarService do
  # import Ecto.Query
  use UcxChat.Web, :service
  import UcxChat.UserChannel
  import Phoenix.Socket, only: [assign: 3]

  alias UcxChat.{Repo, FlexBarView, User, Mention, StaredMessage, PinnedMessage,
    UserAgent, Permission, Direct, Channel, Notification, AccountService}
  # alias UcxChat.ServiceHelpers, as: Helpers

  require Logger
  require IEx

  def handle_in("close" = _event, msg) do
    # Logger.warn "FlexBarService.close msg: #{inspect msg}"
    UserAgent.close_ftab(msg["user_id"], msg["channel_id"])
    {:ok, %{}}
  end

  def handle_in("get_open" = _event, msg) do
    Logger.debug "FlexBarService.get_open msg: #{inspect msg}"
    ftab = UserAgent.get_ftab(msg["user_id"], msg["channel_id"])
    {:ok, %{ftab: ftab}}
  end

  def handle_in("show-all", params, socket) do
    users =
      Channel
      |> Helpers.get!(params["channel_id"], preload: [:users])
      |> get_channel_offline_users

    channel_id = params["channel_id"]
    html =
      for user <- users do
        FlexBarView.render("users_list_item.html", user: user, channel_id: channel_id)
        |> safe_to_string
      end
      |> Enum.join("")

    {:reply, {:ok, %{html: html, selector: ".list-view ul.lines", action: "append"}}, socket}
  end

  def handle_in(ev = "notifications_form:edit", params, socket) do
    args = [notification: socket.assigns.notification, editing: params["field"]]
    html =
      "notifications.html"
      |> FlexBarView.render(args)
      |> Phoenix.HTML.safe_to_string
    {:reply, {:ok, %{html: html}}, assign(socket, :notifications_edit, params["field"])}
  end

  def handle_in(ev = "notifications_form:cancel", params, socket) do
    html =
      "notifications.html"
      |> FlexBarView.render([notification: socket.assigns.notification, editing: ""])
      |> Phoenix.HTML.safe_to_string

    {:reply, {:ok, %{html: html}}, assign(socket, :notifications_edit, nil)}
  end

  def handle_in(ev = "notifications_form:play", params, socket) do
    user = Helpers.get_user(socket.assigns.user_id)
    sound = UcxChat.Settings.get_new_message_sound(user, socket.assigns.channel_id)
    {:reply, {:ok, %{sound: sound}}, socket}
  end

  def handle_in(ev = "notifications_form:save", params, socket) do
    notify = socket.assigns.notification
    params =
      params
      |> Enum.reduce(%{"settings" => %{"id" => notify.settings.id}}, fn %{"name" => name, "value" => value}, acc ->
        "notification[settings][" <> name = name
        put_in acc, ["settings", String.replace(name, "]", "")], value
      end)
    case AccountService.update_notification notify, params do
      {:ok, notify} ->
        Phoenix.Channel.push(socket, "toastr:success", %{message: ~g(Setting was successfully updated.)})
        html =
          "notifications.html"
          |> FlexBarView.render([notification: notify, editing: ""])
          |> Phoenix.HTML.safe_to_string
        {:reply, {:ok, %{html: html}}, assign(socket, :notifications_edit, nil) |> assign(:notification, notify)}
      {:error, cs} ->
        Logger.warn "error cs: #{inspect cs}"
        {:reply, {:error, %{error: ~g(There was a problem updating that setting)}}, socket}
    end
  end

  def handle_flex_callback(:open, _ch, "Notifications" = tab, nil, socket, _params) do
    user_id = socket.assigns[:user_id]
    channel_id = socket.assigns[:channel_id]
    case default_settings()[String.to_atom(tab)][:templ] do
      nil -> %{}
      templ ->
        [{:notification, notify} | _] = args = get_render_args(tab, user_id, channel_id, nil)
        html =
          templ
          |> FlexBarView.render(args)
          |> Phoenix.HTML.safe_to_string
        %{html: html, notification: notify}
    end
  end
  def handle_flex_callback(:open, _ch, tab, nil, socket, _params) do
    user_id = socket.assigns[:user_id]
    channel_id = socket.assigns[:channel_id]
    case default_settings()[String.to_atom(tab)][:templ] do
      nil -> %{}
      templ ->
        html =
          templ
          |> FlexBarView.render(get_render_args(tab, user_id, channel_id, nil))
          |> Phoenix.HTML.safe_to_string
        %{html: html}
    end
  end
  def handle_flex_callback(:open, _ch, tab, args, socket, _params) do
    user_id = socket.assigns[:user_id]
    channel_id = socket.assigns[:channel_id]
    case default_settings()[String.to_atom(tab)][:templ] do
      nil -> %{}
      templ ->
        html =
          templ
          |> FlexBarView.render(get_render_args(tab, user_id, channel_id, nil, args))
          |> Phoenix.HTML.safe_to_string
        %{html: html}
    end
  end

  # def handle_flex_callback(:close, ch, tab, params, _) do
  # end


  def handle_click("Info" = event, %{"channel_id" => channel_id} = msg)  do
    log_click event, msg

    handle_open_close event, msg, fn msg ->
      # args = Helpers.get_channel(channel_id)
      args = get_render_args("Info", msg["user_id"], channel_id, nil, nil)

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      UserAgent.open_ftab(msg["user_id"], channel_id, event, nil)

      %{html: html}
    end
  end

  def handle_click("Members List" = event, %{"channel_id" => channel_id} = msg)  do
    log_click event, msg

    handle_open_close event, msg, fn msg ->
      args = get_render_args("Members List", msg["user_id"], channel_id, nil, msg)

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      view = if msg["username"], do: {"username", msg["username"]}, else: nil

      UserAgent.open_ftab(msg["user_id"], channel_id, event, view)

      %{html: html}
    end
  end


  def handle_click("Switch User" = event, msg) do
    log_click event, msg

    handle_open_close event, msg, fn msg ->
      args = get_render_args("Switch User", nil, nil, nil, nil)

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      UserAgent.open_ftab(msg["user_id"], msg["channel_id"], event, nil)

      %{html: html}
    end
  end

  def handle_click("Mentions" = event, %{"user_id" => user_id, "channel_id" => channel_id} = msg) do
    log_click event, msg
    handle_open_close event, msg, fn msg ->

      args = get_render_args("Mentions", user_id, channel_id, nil)

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      UserAgent.open_ftab(msg["user_id"], msg["channel_id"], event, nil)

      %{html: html}
    end
  end

  def handle_click("Stared Messages" = event, %{"user_id" => user_id, "channel_id" => channel_id} = msg) do
    log_click event, msg

    handle_open_close event, msg, fn msg ->
      args = get_render_args("Stared Messages", user_id,  channel_id, msg["message_id"])

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      UserAgent.open_ftab(msg["user_id"], msg["channel_id"], event, nil)

      %{html: html}
    end
  end
  def handle_click("Pinned Messages" = event, %{"user_id" => user_id, "channel_id" => channel_id} = msg) do
    log_click event, msg
    handle_open_close event, msg, fn  msg ->
      args = get_render_args("Pinned Messages", user_id, channel_id, msg["message_id"])

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      UserAgent.open_ftab(msg["user_id"], msg["channel_id"], event, nil)

      %{html: html}
    end
  end

  # def handle_click("User Info" = event, %{"user_id" => user_id, "channel_id" => channel_id} = msg) do
  #   log_click event, msg
  #   handle_open_close event, msg, fn  msg ->
  #     args = get_render_args("Pinned Messages", user_id, channel_id, msg["message_id"])

  #     html = FlexBarView.render(msg["templ"], args)
  #     |> Phoenix.HTML.safe_to_string

  #     UserAgent.open_ftab(msg["user_id"], msg["channel_id"], event, nil)

  #     %{html: html}
  #   end
  # end

  def handle_open_close(event, msg, fun) do
    case UserAgent.get_ftab(msg["user_id"], msg["channel_id"]) do
      %{title: ^event} ->
        UserAgent.close_ftab(msg["user_id"], msg["channel_id"])
        {:ok, %{close: true}}
      _ ->
        {:ok, Map.put(fun.(msg), :open, true)}
    end
  end

  def settings_form_fields(channel, user_id) do
    user = Helpers.get_user! user_id
    disabled = !Permission.has_permission?(user, "edit-room", channel.id)
    [
      %{name: "name", label: ~g"Name", type: :text, value: channel.name, read_only: disabled},
      %{name: "topic", label: ~g"Topic", type: :text, value: channel.topic, read_only: disabled},
      %{name: "description", label: ~g"Description", type: :text, value: channel.description, read_only: disabled},
      %{name: "private", label: ~g"Private", type: :boolean, value: channel.type == 1, read_only: disabled},
      %{name: "read_only", label: ~g"Read only", type: :boolean, value: channel.read_only, read_only: disabled},
      %{name: "archived", label: ~g"Archived", type: :boolean, value: channel.archived, read_only: disabled},
      %{name: "password", label: ~g"Password", type: :text, value: "", read_only: true},
    ]
  end

  def get_setting_form_field(name, channel, user_id) do
    settings_form_fields(channel, user_id)
    |> Enum.find(&(&1[:name] == name))
  end

  def get_render_args(event, user_id, channel_id, message_id, opts \\ %{})

  def get_render_args("Info", user_id, channel_id, _, _)  do
    current_user = Helpers.get_user! user_id
    channel = Helpers.get_channel(channel_id)
    [channel: settings_form_fields(channel, user_id), current_user: current_user, channel_type: channel.type]
  end

  def get_render_args("Notifications", user_id, channel_id, _, _)  do
    current_user = Helpers.get_user! user_id
    notification =
      current_user.account
      |> Notification.get_notification(channel_id)
      |> Repo.one
      |> case do
        nil -> AccountService.new_notification(current_user.account.id, channel_id)
        notification -> notification
      end

    [notification: notification, editing: nil]
  end

  def get_render_args("User Info", user_id, channel_id, _, _)  do
    current_user = Helpers.get_user! user_id
    channel = Helpers.get_channel(channel_id)
    direct = (from d in Direct,
      where: d.user_id == ^user_id and d.channel_id == ^(channel.id))
    |> Repo.one

    user = Helpers.get_user_by_name(direct.users, [:roles, :account])
    user_info = user_info(channel, direct: true)
    [user: user, current_user: current_user, channel_id: channel_id, user_info: user_info]
  end

  def get_render_args("Members List", user_id, channel_id, _message_id, opts) do
    current_user = Helpers.get_user!(user_id)
    channel = Helpers.get_channel(channel_id, [users: :roles])

    {user, user_mode} =
      case opts["username"] do
        nil -> {Helpers.get_user!(user_id), false}
        username -> {Helpers.get_by(User, :username, username, preload: [:roles]), true}
      end

    users = get_all_channel_online_users(channel)

    total_count = channel.users |> length

    user_info =
      channel
      |> user_info(user_mode: user_mode, view_mode: true)
      |> Map.put(:total_count, total_count)

    [users: users, user: user, user_info: user_info, channel_id: channel_id, current_user: current_user]
  end

  def get_render_args("Switch User", _, _, _, _) do
    [users: Repo.all(User)]
  end

  def get_render_args("Mentions", user_id, channel_id, _message_id, _) do
    mentions =
      Mention
      |> where([m], m.user_id == ^user_id and m.channel_id == ^channel_id)
      |> preload([:user, :message])
      |> Repo.all
      |> Enum.reduce({nil, []}, fn m, {last_day, acc} ->
        day = DateTime.to_date(m.updated_at)
        msg =
          %{
            channel_id: channel_id,
            message: m.message,
            username: m.user.username,
            user: m.user,
            own: m.message.user_id == user_id,
            id: m.id,
            new_day: day != last_day,
            date: Helpers.format_date(m.message.updated_at),
            time: Helpers.format_time(m.message.updated_at),
            timestamp: m.message.timestamp
          }
        {day, [msg|acc]}
      end)
      |> elem(1)
      |> Enum.reverse

    [mentions: mentions]
  end
  def get_render_args("Stared Messages", user_id,  channel_id, _message_id, _) do
    stars =
      StaredMessage
      |> where([m], m.channel_id == ^channel_id)
      |> preload([:user, :message])
      |> order_by([m], desc: m.id)
      |> Repo.all
      |> Enum.reduce({nil, []}, fn m, {last_day, acc} ->
        day = DateTime.to_date(m.updated_at)
        msg =
          %{
            channel_id: channel_id,
            message: m.message,
            username: m.user.username,
            user: m.user,
            own: m.message.user_id == user_id,
            id: m.id,
            new_day: day != last_day,
            date: Helpers.format_date(m.message.updated_at),
            time: Helpers.format_time(m.message.updated_at),
            timestamp: m.message.timestamp
          }
        {day, [msg|acc]}
      end)
      |> elem(1)
      |> Enum.reverse
    [stars: stars]
  end

  def get_render_args("Pinned Messages", user_id, channel_id, _message_id, _) do
    pinned =
      PinnedMessage
      |> where([m], m.channel_id == ^channel_id)
      |> preload([message: :user])
      |> order_by([p], desc: p.id)
      |> Repo.all
      |> Enum.reduce({nil, []}, fn p, {last_day, acc} ->
        day = DateTime.to_date(p.updated_at)
        msg =
          %{
            channel_id: channel_id,
            message: p.message,
            username: p.message.user.username,
            user: p.message.user,
            own: p.message.user_id == user_id,
            id: p.id,
            new_day: day != last_day,
            date: Helpers.format_date(p.message.updated_at),
            time: Helpers.format_time(p.message.updated_at),
            timestamp: p.message.timestamp
          }
        {day, [msg|acc]}
      end)
      |> elem(1)
      |> Enum.reverse

    [pinned: pinned]
  end

  def get_all_channel_users(channel) do
    channel.users
    |> Enum.map(fn user ->
      struct(user, status: UcxChat.PresenceAgent.get(user.id))
    end)
  end

  def get_all_channel_online_users(channel) do
    channel
    |> get_all_channel_users
    |> Enum.reject(&(&1.status == "offline"))
  end

  def get_channel_offline_users(channel) do
    channel
    |> get_all_channel_users
    |> Enum.filter(&(&1.status == "offline"))
  end

  def user_info(channel, opts \\ []) do
    show_admin = opts[:admin] || false
    direct = opts[:direct] || false
    user_mode = opts[:user_mode] || false
    view_mode = opts[:view_mode] || false

    %{direct: direct, show_admin: show_admin, blocked: channel.blocked, user_mode: user_mode, view_mode: view_mode}
  end

  def default_settings do
    switch_user =
      if Application.get_env(:ucx_chat, :switch_user) && UcxChat.env() != :prod do
        %{templ: "switch_user_list.html", args: %{}}
      else
        %{hidden: true}
      end
    %{
      "IM Mode": %{},
      "Rooms Mode": %{},
      "Info": %{templ: "channel_settings.html", args: %{} },
      "Search": %{},
      "User Info": %{templ: "user_card.html", args: %{}},
      "Members List": %{
        templ: "users_list.html",
        args: %{},
        show: %{
          attr: "data-username",
          args: [%{key: "username"}], # attr is optional for override -  attr: "data-username"}],
          triggers: [
            %{action: "click", class: "button.user.user-card-message"},
            %{action: "click", class: ".mention-link"},
            %{action: "click", class: "li.user-card-room button"},
            %{function: "custom_show_switch_user"}
          ]
        }
       },
      "Notifications": %{templ: "notifications.html", args: %{}},
      "Files List": %{},
      "Mentions": %{templ: "mentions.html", args: %{} },
      "Stared Messages": %{templ: "stared_messages.html", args: %{}},
      "Knowledge Base": %{hidden: true},
      "Pinned Messages": %{templ: "pinned_messages.html", args: %{}},
      "Past Chats": %{hidden: true},
      "OTR": %{hidden: true},
      "Video Chat": %{hidden: true},
      "Snippeted Messages": %{},
      "Logout": %{function: "function() { window.location.href = '/logout'}" },
      "Switch User": switch_user
    }
  end

  def visible_tab_names do
    default_settings()
    |> Enum.filter_map(&(elem(&1, 1)[:hidden] != true), &(to_string elem(&1, 0)))
  end

  defp log_click(event, msg, level \\ :debug) do
    Logger.log level, "FlexBarService.handle_click #{event}: #{inspect msg}"
  end

end
