defmodule UcxChat.SlashCommandsService do
  alias UcxChat.{SlashCommands, Repo, Message, Client, Channel, Subscription}
  alias UcxChat.{ChannelService, MessageService}
  alias UcxChat.ServiceHelpers, as: Helpers

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

  def handle_command("topic " <> args, client_id, channel_id) do
    channel =
      Channel
      |> where([c], c.id == ^channel_id)
      |> Repo.one!
      |> Channel.changeset(%{topic: args})
      |> Repo.update!
    # {:broadcast, {"room:update_topic", %{room: channel.name, topic: args}}}
    {:ok, %{}}
  end

  def handle_command("create " <> args, client_id, channel_id) do
    with "#" <> name <- String.trim(args),
         true <- String.match?(name, ~r/[a-z0-9\.\-_]/i) do
     {:ok, ChannelService.create_channel(name, client_id, channel_id)}
    else
      _ ->
        {:ok, Helpers.error_message(channel_id, text: "Invalid channel name:", code: args)}
    end
  end

  # unknown command
  def handle_command(command, client_id, channel_id) do
    Logger.warn "SlashCommandsService unrecognized command: #{inspect command}"
    {:ok, Helpers.error_message(channel_id, text: "No such command: ", code: command)}
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
