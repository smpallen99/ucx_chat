defmodule UcxChat.FlexBarService do
  import Ecto.Query

  alias UcxChat.{Repo, FlexBarView, Client, User, Mention, StaredMessage, PinnedMessage, ClientAgent}
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger
  require IEx

  def handle_in("close" = _event, msg) do
    # Logger.warn "FlexBarService.close msg: #{inspect msg}"
    ClientAgent.close_ftab(msg["client_id"], msg["channel_id"])
    {:ok, %{}}
  end

  def handle_in("get_open" = _event, msg) do
    Logger.debug "FlexBarService.get_open msg: #{inspect msg}"
    ftab = ClientAgent.get_ftab(msg["client_id"], msg["channel_id"])
    {:ok, %{ftab: ftab}}
  end

  def handle_flex_callback(:open, _ch, tab, nil, socket, _params) do
    client_id = socket.assigns[:client_id]
    channel_id = socket.assigns[:channel_id]
    case default_settings[String.to_atom(tab)][:templ] do
      nil -> %{}
      templ ->
        html =
          templ
          |> FlexBarView.render(get_render_args(tab, client_id, channel_id, nil))
          |> Phoenix.HTML.safe_to_string
        %{html: html}
    end
  end
  def handle_flex_callback(:open, _ch, tab, args, socket, _params) do
    # require IEx
    # IEx.pry
    client_id = socket.assigns[:client_id]
    channel_id = socket.assigns[:channel_id]
    case default_settings[String.to_atom(tab)][:templ] do
      nil -> %{}
      templ ->
        html =
          templ
          |> FlexBarView.render(get_render_args(tab, client_id, channel_id, nil, args))
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
      args = get_render_args("Info", msg["client_id"], channel_id, nil, nil)

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      ClientAgent.open_ftab(msg["client_id"], channel_id, event, nil)

      %{html: html}
    end
  end

  def handle_click("Members List" = event, %{"channel_id" => channel_id} = msg)  do
    log_click event, msg

    handle_open_close event, msg, fn msg ->
      args = get_render_args("Members List", msg["client_id"], channel_id, nil, msg)

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      view = if msg["nickname"], do: {"nickname", msg["nickname"]}, else: nil

      ClientAgent.open_ftab(msg["client_id"], channel_id, event, view)

      %{html: html}
    end
  end


  def handle_click("Switch User" = event, msg) do
    log_click event, msg

    handle_open_close event, msg, fn msg ->
      args = get_render_args("Switch User", nil, nil, nil, nil)

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      ClientAgent.open_ftab(msg["client_id"], msg["channel_id"], event, nil)

      %{html: html}
    end
  end

  def handle_click("Mentions" = event, %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    log_click event, msg
    handle_open_close event, msg, fn msg ->

      args = get_render_args("Mentions", client_id, channel_id, nil)

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      ClientAgent.open_ftab(msg["client_id"], msg["channel_id"], event, nil)

      %{html: html}
    end
  end

  def handle_click("Stared Messages" = event, %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    log_click event, msg

    handle_open_close event, msg, fn msg ->
      args = get_render_args("Stared Messages", client_id,  channel_id, msg["message_id"])

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      ClientAgent.open_ftab(msg["client_id"], msg["channel_id"], event, nil)

      %{html: html}
    end
  end
  def handle_click("Pinned Messages" = event, %{"client_id" => client_id, "channel_id" => channel_id} = msg) do
    log_click event, msg
    handle_open_close event, msg, fn  msg ->
      args = get_render_args("Pinned Messages", client_id, channel_id, msg["message_id"])

      html = FlexBarView.render(msg["templ"], args)
      |> Phoenix.HTML.safe_to_string

      ClientAgent.open_ftab(msg["client_id"], msg["channel_id"], event, nil)

      %{html: html}
    end
  end

  def handle_open_close(event, msg, fun) do
    case ClientAgent.get_ftab(msg["client_id"], msg["channel_id"]) do
      %{title: ^event} ->
        ClientAgent.close_ftab(msg["client_id"], msg["channel_id"])
        {:ok, %{close: true}}
      _ ->
        {:ok, Map.put(fun.(msg), :open, true)}
    end
  end

  def settings_form_fields(channel, client_id) do
    disabled = channel.client_id != client_id
    [
      %{name: "name", label: "Name", type: :text, value: channel.name, read_only: disabled},
      %{name: "topic", label: "Topic", type: :text, value: channel.topic, read_only: disabled},
      %{name: "description", label: "Description", type: :text, value: channel.description, read_only: disabled},
      %{name: "private", label: "Private", type: :boolean, value: channel.type == 1, read_only: disabled},
      %{name: "read_only", label: "Read only", type: :boolean, value: channel.read_only, read_only: disabled},
      %{name: "archived", label: "Archived", type: :boolean, value: channel.archived, read_only: disabled},
      %{name: "password", label: "Password", type: :text, value: "", read_only: true},
    ]
  end

  def get_setting_form_field(name, channel, client_id) do
    settings_form_fields(channel, client_id)
    |> Enum.find(&(&1[:name] == name))
  end

  def get_render_args(event, client_id, channel_id, message_id, opts \\ %{})

  def get_render_args("Info", client_id, channel_id, _, _)  do
    channel = Helpers.get_channel(channel_id)
    [channel: settings_form_fields(channel, client_id)]
  end

  def get_render_args("Members List", client_id, channel_id, _message_id, opts) do
    channel = Helpers.get_channel(channel_id, [:clients])

    {client, user_mode} =
      case opts["nickname"] do
        nil -> {Helpers.get(Client, client_id), false}
        nickname -> {Helpers.get_by(Client, :nickname, nickname), true}
      end

    [clients: channel.clients, client: client, user_mode: user_mode]
  end

  def get_render_args("Switch User", _, _, _, _) do
    [users: Repo.all(User)]
  end

  def get_render_args("Mentions", client_id, channel_id, _message_id, _) do
    mentions =
      Mention
      |> where([m], m.client_id == ^client_id and m.channel_id == ^channel_id)
      |> preload([:client, :message])
      |> Repo.all
      |> Enum.reduce({nil, []}, fn m, {last_day, acc} ->
        day = DateTime.to_date(m.updated_at)
        msg =
          %{
            channel_id: channel_id,
            message: m.message,
            nickname: m.client.nickname,
            client: m.client,
            own: m.message.client_id == client_id,
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
  def get_render_args("Stared Messages", client_id,  channel_id, _message_id, _) do
    stars =
      StaredMessage
      |> where([m], m.channel_id == ^channel_id)
      |> preload([:client, :message])
      |> order_by([m], desc: m.id)
      |> Repo.all
      |> Enum.reduce({nil, []}, fn m, {last_day, acc} ->
        day = DateTime.to_date(m.updated_at)
        msg =
          %{
            channel_id: channel_id,
            message: m.message,
            nickname: m.client.nickname,
            client: m.client,
            own: m.message.client_id == client_id,
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

  def get_render_args("Pinned Messages", client_id, channel_id, _message_id, _) do
    pinned =
      PinnedMessage
      |> where([m], m.channel_id == ^channel_id)
      |> preload([message: :client])
      |> order_by([p], desc: p.id)
      |> Repo.all
      |> Enum.reduce({nil, []}, fn p, {last_day, acc} ->
        day = DateTime.to_date(p.updated_at)
        msg =
          %{
            channel_id: channel_id,
            message: p.message,
            nickname: p.message.client.nickname,
            client: p.message.client,
            own: p.message.client_id == client_id,
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

  def default_settings do
    %{
      "Info": %{templ: "channel_settings.html", args: %{} },
      "Search": %{},
      "User Info": %{},
      "Members List": %{
        templ: "clients_list.html",
        args: %{},
        show: %{
          attr: "data-username",
          args: [%{key: "nickname"}], # attr is optional for override -  attr: "data-username"}],
          triggers: [
            %{action: "click", class: "button.user.user-card-message"},
            %{action: "click", class: ".mention-link"},
            %{action: "click", class: "li.user-card-room button"},
            %{function: "custom_show_switch_user"}
          ]
        }
       },
      "Notifications": %{},
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
      "Switch User": %{templ: "switch_user_list.html", args: %{}}
    }
  end

  def visible_tab_names do
    default_settings
    |> Enum.filter_map(&(elem(&1, 1)[:hidden] != true), &(to_string elem(&1, 0)))
  end

  defp log_click(event, msg, level \\ :debug) do
    Logger.log level, "FlexBarService.handle_click #{event}: #{inspect msg}"
  end

end
