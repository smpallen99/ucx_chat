defmodule UcxChat.SlashCommandsService do
  alias UcxChat.{SlashCommands, Repo, Message, MessageService, Client}

  import Ecto.Query

  require Logger

  @commands [
    "join", "archive", "kick", "lennyface", "leave", "gimme", "create", "invite",
    "invite-all-to", "invite-all-from", "msg", "part", "unarchive", "tableflip",
    "topic", "mute", "me", "open", "unflip", "shrug", "unmute" ]

  def handle_in(command, msg, socket) do
    Logger.warn "SlashCommandsService.handle_in command: #{inspect command}, msg: #{inspect msg}"
    res = handle_command(command, msg["client_id"], msg["channel_id"])
    {:reply, res, socket}
  end

  def handle_command("gimme" <> args, client_id, channel_id),
    do: handle_command_text("gimme", args, client_id, channel_id)
  def handle_command("lennyface" <> args, client_id, channel_id),
    do: handle_command_text("lennyface", args, client_id, channel_id, true)
  def handle_command("tableflip" <> args, client_id, channel_id),
    do: handle_command_text("tableflip", args, client_id, channel_id, true)
  def handle_command("unflip" <> args, client_id, channel_id),
    do: handle_command_text("unflip", args, client_id, channel_id, true)
  def handle_command("shrug" <> args, client_id, channel_id),
    do: handle_command_text("shrug", args, client_id, channel_id, true)

  def handle_command("create " <> args, client_id, channel_id) do

    {:ok, %{}}
  end
  def handle_command(command, client_id, channel_id) do
    Logger.warn "SlashCommandsService unrecognized command: #{inspect command}"

    body = UcxChat.MessageView.render("no_such_command_body.html", command: command)
    |> Phoenix.HTML.safe_to_string

    bot_id =
      Client
      # |> where([m], m.type == "b")
      |> select([m], m.id)
      |> limit(1)
      |> Repo.one

    message = MessageService.create_message(body, bot_id, channel_id,
      %{
        type: "p",
        sequential: false,
      })

    html = MessageService.render_message(message)

    {:ok, %{html: html}}
  end

  defp handle_command_text(command, args, client_id, channel_id, prepend \\ false) do
    body = if prepend do
      args <> " " <> SlashCommands.special_text(command)
    else
      SlashCommands.special_text(command) <> args
    end
    message = MessageService.create_message(body, client_id, channel_id)
    {:ok, %{html: MessageService.render_message(message)}}
  end
end
