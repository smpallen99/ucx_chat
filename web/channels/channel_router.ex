defmodule ChannelRouter do

  defmacro __using__(_ \\ []) do
    quote do
      import unquote(__MODULE__)
      require Logger

      def route(socket, pattern, params, ucxchat) do
        # Logger.info " route: ucxchat: #{inspect ucxchat}"
        verb = ucxchat["verb"] |> String.to_atom

        assigns =
          ucxchat["assigns"]
          |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end)
          |> Enum.into(%{})
          |> Map.merge(socket.assigns)

        matches = String.split(pattern, "/", trim: true)

        socket = struct(socket, assigns: assigns)
        apply(__MODULE__, :match, [verb, socket, matches, params])
      end

    end
  end

  defmacro get(path, ctrl, action) do
    compile(:get, path, ctrl, action)
  end

  defmacro post(path, ctrl, action) do
    compile(:post, path, ctrl, action)
  end

  defmacro put(path, ctrl, action) do
    compile(:put, path, ctrl, action)
  end

  defmacro delete(path, ctrl, action) do
    compile(:delete, path, ctrl, action)
  end


  def compile(_method, _expr, _ctrl, _action) do

  end

end
  # MessageCogService
  # open -> show
  # star-message
  # unstar-message
  # pin-message
  # unpin-message

  # TypingController
  # post "/", TypingController, :create
  # delete "/", TypingController, :delete

  # MessageCogController
  # get "/:message_id", CogController, :show # -> open
  # put /:message_id/star, CogController, :update_star
  # put /:message_id/pin, CogController, :update_pin
  #
  # MessagePopupService
  # get "/users",
  # get:channels
  # get:slashcommands
  #
  # MessageService
  # load
  # get_messages
  # last_user_id
  # new_message
  # render message

  # FlexBarService
  # close
  # get_open
  # form:click
  # form:cancel
  # form:save
  # Info
  # Members List
  # Switch User
  # Mentions
  # Stared Messages
  # ...

  # ChannelService
  # toggle-favorite (room)
  # add_direct
  # channel_commands - used by slash commands

  # SlashCommandService
  # handle_command (many of them)

