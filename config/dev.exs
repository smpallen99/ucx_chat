use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :ucx_chat, UcxChat.Endpoint,
  http: [port: 4015],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../", __DIR__)]]

config :logger, level: :info

# Watch static and templates for browser reloading.
config :ucx_chat, UcxChat.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex|haml)$}
    ]
  ]

config :ucx_chat,
  debug: false,
  # debug: true,
  switch_user: false,
  twillo_sid: "CHANGE_ME",
  twillo_authtoken: "CHANGE_ME"

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  format: "[$level] $metadata $message\n",
  metadata: [:module, :line, :function]

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :ucx_chat, UcxChat.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASS"),
  database: "ucx_chat_dev",
  hostname: "localhost",
  pool_size: 10
