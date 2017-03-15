defmodule UcxChat.AppConfig do
  defmacro __using__(_) do
    quote do
      alias unquote(__MODULE__)
    end
  end

  require Logger

  # opts: :all || [:trackable, :lockable, :rememberable, :confirmable]
  [
    {:page_size, 150}
    # :page_size,
    # {:token_assigns_key, :user_token},
  ]
  |> Enum.each(fn
        {key, default} ->
          def unquote(key)(opts \\ unquote(default)) do
            # get_application_env unquote(key), opts
            Application.get_env :ucx_chat, unquote(key), opts
          end
        key ->
          def unquote(key)(opts \\ nil) do
            # get_application_env unquote(key), opts
            Application.get_env :ucx_chat, unquote(key), opts
          end
     end)

  # defp get_application_env(key, default \\ nil) do
  #   case Application.get_env :ucx_chat, key, default do
  #     {:system, env_var} -> System.get_env env_var
  #     value -> value
  #   end
  # end
end
