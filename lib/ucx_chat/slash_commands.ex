defmodule UcxChat.SlashCommands do
  import Phoenix.HTML.Tag

  @default_count 10

  @commands [
    "join", "archive", "kick", "lennyface", "leave", "gimme", "create", "invite",
    "invite-all-to", "invite-all-from", "msg", "part", "unarchive", "tableflip",
    "topic", "mute", "me", "open", "unflip", "shrug", "unmute" ]
  # commands = [
  #   "join", "archive", "kick", "lennyface", "leave", "gimme", "create", "invite",
  #   "invite-all-to", "invite-all-from", "msg", "part", "unarchive", "tableflip",
  #   "topic", "mute", "me", "open", "unflip", "shrug", "unmute" ]

  @special_text %{
    "gimme" => "༼ つ ◕_◕ ༽つ",
    "lennyface" => "( ͡° ͜ʖ ͡°)",
    "tableflip" => "(╯°□°）╯︵ ┻━┻",
    "unflip" => "┬─┬﻿ ノ( ゜-゜ノ)",
    "shrug" => "¯\_(ツ)_/¯",
  }

  @command_data [
    %{command: "join", args: "#channel", description: "Join the given channel"},
    %{command: "archive", args: "#channel", description: "Archive"},
    %{command: "kick", args: "@username", description: "Remove someone from the room"},
    %{command: "lennyface", args: "your message (optional)", description: "Displays ( ͡° ͜ʖ ͡°) after your message"},
    %{command: "leave", args: "", description: "Leave the current channel"},
    %{command: "gimme", args: "your message (optional)", description: "Displays ༼ つ ◕_◕ ༽つ before your message"},
    %{command: "create", args: "#channel", description: "Create a new channel"},
    %{command: "invite", args: "@username", description: "invite one user to join this channel"},
    %{command: "invite-all-to", args: "#room", description: "Invite all users from this channel to join [#channel]"},
    %{command: "invite-all-from", args: "#room", description: "Invite all users from [#channel] to join this channel"},
    %{command: "msg", args: "@username <message>", description: "Direct message someone"},
    %{command: "part", args: "", description: "Leave the current channel"},
    %{command: "unarchive", args: "#channel", description: "Unarchive"},
    %{command: "tableflip", args: "your message (optional)", description: "Displays (╯°□°）╯︵ ┻━┻"},
    %{command: "topic", args: "Topic message", description: "Set topic"},
    %{command: "mute", args: "@username", description: "Mute someone in the room"},
    %{command: "me", args: "your message", description: "Display action text"},
    %{command: "open", args: "room name", description: "Opens a channel, group or direct message"},
    %{command: "unflip", args: "your message (optional)", description: "Displays ┬─┬﻿ ノ( ゜-゜ノ)"},
    %{command: "shrug", args: "your message (optional)", description: "Displays ¯\_(ツ)_/¯ after your message"},
    %{command: "unmute", args: "@username", description: "Unmute someone in the room"}
  ]

  @command_map @command_data |> Enum.reduce(%{}, fn %{command: command} = map, acc -> Map.put(acc, command, map) end)

  def commands(pattern, count \\ @default_count) do
    pattern
    |> find(count)
    |> Enum.reduce([], fn
      cmd, [] -> [format_command(@command_map[cmd], " selected")]
      cmd, acc -> [format_command(@command_map[cmd])|acc]
    end)
    |> Enum.reverse
    |> case do
      [] -> nil
      list ->
        content_tag :div, class: "message-popup-items" do
          list
        end
    end
  end

  def find(pattern, count \\ @default_count)

  def find("", count), do: Enum.take(@commands, count)

  def find(pattern, count) do
    @commands
    |> Enum.reduce([], fn command, acc ->
      if String.contains?(command, pattern), do: [command|acc], else: acc
    end)
    |> Enum.sort
    |> Enum.take(count)
  end

  def format_command %{command: command, args: args, description: description}, class \\ "" do
    content_tag :div, class: "popup-item#{class}", "data-name": command do
      [
        content_tag :strong do
          ["/", command]
        end,
        [" "],
        args,
        content_tag :div, class: "popup-slash-command-description" do
          content_tag :i do
            description
          end
        end
      ]
    end
  end
  def special_text(message), do: @special_text[message]
end
