defmodule UcxChat.MessagePopupService do
  require Logger
  alias UcxChat.{Repo, User, Channel, Message, SlashCommands}
  # alias UcxChat.ServiceHelpers, as: Helpers
  import Ecto.Query

  def handle_in("get:users" <> _mod, msg) do
    Logger.debug "get:users, msg: #{inspect msg}"
    pattern = msg["pattern"] |> to_string
    users = get_users_by_pattern(msg["channel_id"], msg["user_id"], "%" <> pattern <> "%")

    if length(users) > 0 do
      data = users ++ [
        %{system: true, username: "all", name: "Notify all in this room", id: "all"},
        %{system: true, username: "here", name: "Notify active users in this room", id: "here"}
      ]
      chatd = %{open: true, title: "People", data: data, templ: "popup_user.html"}

      html =
        "popup.html"
        |> UcxChat.MessageView.render(chatd: chatd)
        |> Phoenix.HTML.safe_to_string

      {:ok, %{html: html}}
    else
      {:ok, %{close: true}}
    end
  end

  def handle_in("get:channels" <> _mod, msg) do
    Logger.debug "get:channels, msg: #{inspect msg}"
    pattern = msg["pattern"] |> to_string
    channels = get_channels_by_pattern(msg["channel_id"], msg["user_id"], "%" <> pattern <> "%")

    if length(channels) > 0 do
      chatd = %{open: true, title: "Channels", data: channels, templ: "popup_channel.html"}

      html =
        "popup.html"
        |> UcxChat.MessageView.render(chatd: chatd)
        |> Phoenix.HTML.safe_to_string

      {:ok, %{html: html}}
    else
      {:ok, %{close: true}}
    end
  end

  def handle_in("get:slashcommands" <> _mod, msg) do
    Logger.debug "get:slashcommands, msg: #{inspect msg}"
    pattern = msg["pattern"] |> to_string

    if commands = SlashCommands.commands(pattern) do
      chatd = %{open: true, data: commands}

      html =
        "popup_slash_commands.html"
        |> UcxChat.MessageView.render(chatd: chatd)
        |> Phoenix.HTML.safe_to_string

      {:ok, %{html: html}}
    else
      {:ok, %{close: true}}
    end
  end

  def get_users_by_pattern(channel_id, user_id, pattern) do
    channel_users = get_default_users(channel_id, user_id, pattern)
    case length channel_users do
      max when max >= 5 -> channel_users
      size ->
        exclude = [user_id|Enum.map(channel_users, &(&1[:id]))]
        channel_users ++ get_all_users(pattern, exclude, 5 - size)
    end
  end

  def get_channels_by_pattern(_channel_id, user_id, pattern) do
    user_id
    |> Channel.get_authorized_channels
    |> where([c], like(c.name, ^pattern))
    |> order_by([c], asc: c.name)
    |> limit(5)
    |> select([c], {c.id, c.name})
    |> Repo.all
    # |> Enum.filter(fn {id, name} -> UcxChat.Permission.has_permission?())
    |> Enum.map(fn {id, name} -> %{id: id, name: name, username: name} end)
  end

  def get_all_users(pattern, exclude, count) do
    User
    |> where([c], like(c.username, ^pattern) and not c.id in ^exclude)
    |> order_by([c], asc: c.username)
    |> limit(^count)
    |> select([c], {c.id, c.username})
    |> Repo.all
    |> Enum.map(fn {id, nn} -> %{id: id, username: nn, status: "online"} end)
  end

  def get_default_users(channel_id, user_id, pattern \\ "%") do
    user_ids =
      Message
      |> where([m], m.channel_id == ^channel_id and m.user_id != ^user_id)
      |> group_by([m], m.user_id)
      |> select([m], m.user_id)
      |> Repo.all
      |> Enum.reverse

    User
    |> where([c], like(c.username, ^pattern) and c.id in ^user_ids)
    |> select([c], {c.id, c.username})
    |> Repo.all
    |> Enum.reverse
    |> Enum.take(5)
    |> Enum.map(fn {id, nn} -> %{username: nn, id: id, status: "online"} end)
  end
end
