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
    user_id = socket.assigns[:user_id]
    channel_id = socket.assigns[:channel_id]
    MessageService.stop_typing(socket, user_id, channel_id)
    command = String.replace(command, "-", "_") |> String.to_atom
    case handle_command(socket, command, args, user_id, channel_id) do
      {:reply, {_, _}, _} = res ->  res
      {:ok, _} = res -> {:reply, res, socket}
      :noreply -> {:noreply, socket}
    end
  end

  def handle_command(socket, :part, args, user_id, channel_id),
    do: handle_channel_command(socket, :leave, args, user_id, channel_id)

  def handle_command(_, :gimme, args, user_id, channel_id),
    do: handle_command_text(:gimme, args, user_id, channel_id)

  @text_commands ~w(lennyface tableflip unflip shrug)a

  def handle_command(_, command, args, user_id, channel_id) when command in @text_commands,
    do: handle_command_text(command, args, user_id, channel_id, true)

  @channel_commands ~w(create join leave open archive unarchive invite_all_from invite_all_to)a

  def handle_command(socket, command, args, user_id, channel_id) when command in @channel_commands,
    do: handle_channel_command(socket, command, args, user_id, channel_id)

  @user_commands ~w(invite kick mute unmute)a
  def handle_command(socket, command, args, user_id, channel_id) when command in @user_commands,
    do: handle_user_command(socket, command, args, user_id, channel_id)

  def handle_command(_, :topic, args, user_id, channel_id) do
    user = Helpers.get_user! user_id
    _channel =
      Channel
      |> where([c], c.id == ^channel_id)
      |> Repo.one!
      |> Channel.do_changeset(user, %{topic: args})
      |> Repo.update!
    # {:broadcast, {"room:update_topic", %{room: channel.name, topic: args}}}
    {:ok, %{}}
  end


  # unknown command
  def handle_command(_, command, args, _user_id, channel_id) do
    command = to_string(command) <> " " <> args
    Logger.warn "SlashCommandsService unrecognized command: #{inspect command}"
    {:ok, Helpers.response_message(channel_id, "No such command: `#{command}`")}
  end

  defp handle_command_text(command, args, user_id, channel_id, prepend \\ false) do
    command = to_string command

    body = if prepend do
      args <> " " <> SlashCommands.special_text(command)
    else
      SlashCommands.special_text(command) <> " " <> args
    end
    Helpers.broadcast_message(body, user_id, channel_id)
    :noreply
    # message = MessageService.create_message(body, user_id, channel_id)
    # {:ok, %{html: MessageService.render_message(message)}}
  end

  def handle_channel_command(socket, command, args, user_id, channel_id) do
    with "#" <> name <- String.trim(args),
         true <- String.match?(name, ~r/[a-z0-9\.\-_]/i) do
      resp = case ChannelService.channel_command(socket, command, name, user_id, channel_id) do
        {:ok, _} ->
          {:ok, %{}}
        {:error, :no_permission}
          {:ok, %{}}
        {:error, error} ->
          Logger.warn "returned error: #{inspect error}"
          {:ok, Helpers.response_message(channel_id, error)}
      end
      {:reply, resp, socket}
    else
      _ ->
        {:reply, {:ok, Helpers.response_message(channel_id, "Invalid channel name: `#{args}`")}, socket}
    end
  end

  def handle_user_command(socket, command, args, user_id, channel_id) do
    with "@" <> name <- String.trim(args),
         true <- String.match?(name, ~r/[a-z0-9\.\-_]/i) do
      resp = case ChannelService.user_command(socket, command, name, user_id, channel_id) do
        {:ok, _msg} ->
          {:ok, %{}}
        {:error, :no_permission} ->
          {:ok, %{}}
        {:error, error} ->
          Logger.warn "returned error: #{inspect error}"
          {:ok, Helpers.response_message(channel_id, error)}
      end
      {:reply, resp, socket}
    else
      _ ->
        {:reply, {:ok, Helpers.response_message(channel_id, "Invalid username: `#{args}`")}, socket}
    end
  end
end
