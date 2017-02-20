defmodule ChannelRouter do

  defmacro __using__(_ \\ []) do
    quote do
      import unquote(__MODULE__)
      require Logger

      def route(socket, pattern, params, ucxchat) do
        Logger.info " route: ucxchat: #{inspect ucxchat}"
        verb = "route_" <> ucxchat["verb"] |> String.to_atom

        assigns =
          ucxchat["assigns"]
          |> Enum.map(fn {k,v} -> {String.to_atom(k), v} end)
          |> Enum.into(%{})
          |> Map.merge(socket.assigns)

        socket = struct(socket, assigns: assigns)
        apply(__MODULE__, verb, [socket, pattern, params])
      end

    end
  end

  defmacro post(pattern, module, action) do

  end

  # defmacro create_route(verb, pattern, module, action) do
  #   pattern = "/" <> route_name(module) <> pattern
  #   quote do
  #     def unquote(verb)(var!(socket), unquote(pattern), )
  #   end
  # end

  # defmacro route(pattern, module, action) do

  # end

  # def route_name(mod) do
  #   mod
  #   |> inspect
  #   |> String.replace(~r/ChannelController$/, "")
  #   |> String.downcase
  # end

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
  # last_client_id
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

