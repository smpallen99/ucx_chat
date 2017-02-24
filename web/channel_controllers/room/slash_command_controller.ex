defmodule UcxChat.SlashCommandChannelController do
  use UcxChat.Web, :channel_controller

  alias UcxChat.{SlashCommands, Repo, Channel}
  alias UcxChat.{ChannelService, MessageService}
  alias UcxChat.ServiceHelpers, as: Helpers

  import Ecto.Query

  require Logger

  @commands [
    "join", "archive", "kick", "lennyface", "leave", "gimme", "create", "invite",
    "invite-all-to", "invite-all-from", "msg", "part", "unarchive", "tableflip",
    "topic", "mute", "me", "open", "unflip", "shrug", "unmute" ]

  def execute(socket, %{"command" => command, "args" => args}) do
    # Logger.warn "SlashCommandsService.execute params: #{inspect params}"
    client_id = socket.assigns[:client_id]
    channel_id = socket.assigns[:channel_id]
    command = String.replace(command, "-", "_") |> String.to_atom
    res = handle_command(command, args, client_id, channel_id)
    {:reply, res, socket}
  end

  def handle_command(:part, args, client_id, channel_id),
    do: handle_channel_command(:leave, args, client_id, channel_id)

  def handle_command(:gimme, args, client_id, channel_id),
    do: handle_command_text(:gimme, args, client_id, channel_id)

  @text_commands ~w(lennyface tableflip unflip shrug)a

  def handle_command(command, args, client_id, channel_id) when command in @text_commands,
    do: handle_command_text(command, args, client_id, channel_id, true)

  @channel_commands ~w(create join leave open archive unarchive invite_all_from invite_all_to)a

  def handle_command(command, args, client_id, channel_id) when command in @channel_commands,
    do: handle_channel_command(command, args, client_id, channel_id)

  @client_commands ~w(invite kick mute unmute)a
  def handle_command(command, args, client_id, channel_id) when command in @client_commands,
    do: handle_client_command(command, args, client_id, channel_id)

  def handle_command(:topic, args, _client_id, channel_id) do
    _channel =
      Channel
      |> where([c], c.id == ^channel_id)
      |> Repo.one!
      |> Channel.changeset(%{topic: args})
      |> Repo.update!
    # {:broadcast, {"room:update_topic", %{room: channel.name, topic: args}}}
    {:ok, %{}}
  end


  # unknown command
  def handle_command(command, args, _client_id, channel_id) do
    command = to_string(command) <> " " <> args
    Logger.warn "SlashCommandsService unrecognized command: #{inspect command}"
    {:ok, Helpers.response_message(channel_id, text: "No such command: ", code: command)}
  end

  defp handle_command_text(command, args, client_id, channel_id, prepend \\ false) do
    command = to_string command

    body = if prepend do
      args <> " " <> SlashCommands.special_text(command)
    else
      SlashCommands.special_text(command) <> " " <> args
    end
    message = MessageService.create_message(body, client_id, channel_id)
    {:ok, %{html: MessageService.render_message(message)}}
  end

  def handle_channel_command(command, args, client_id, channel_id) do
    with "#" <> name <- String.trim(args),
         true <- String.match?(name, ~r/[a-z0-9\.\-_]/i) do
     {:ok, ChannelService.channel_command(command, name, client_id, channel_id)}
    else
      _ ->
        {:ok, Helpers.response_message(channel_id, text: "Invalid channel name:", code: args)}
    end
  end

  def handle_client_command(command, args, client_id, channel_id) do
    with "@" <> name <- String.trim(args),
         true <- String.match?(name, ~r/[a-z0-9\.\-_]/i) do
     {:ok, ChannelService.client_command(command, name, client_id, channel_id)}
    else
      _ ->
        {:ok, Helpers.response_message(channel_id, text: "Invalid username:", code: args)}
    end
  end
end
