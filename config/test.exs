use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ucx_chat, UcxChat.Endpoint,
  http: [port: 4099],
  server: true

# Print only warnings and errors during test
config :logger, level: :error

# Configure your database
config :ucx_chat, UcxChat.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASS"),
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :hound, driver: "phantomjs"
