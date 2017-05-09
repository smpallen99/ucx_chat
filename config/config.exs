# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
#Fishpun is restricted to thisUcxChat.Robot.Adapters.UcxChat project.
use Mix.Config

config :ucx_chat, UcxChat.Robot,
  # adapter: Hedwig.Adapters.Console,
  adapter: UcxChat.Robot.Adapters.UcxChat,
  name: "bot",
  aka: "/",
  responders: [
    {Hedwig.Responders.Help, []},
    {Hedwig.Responders.Ping, []},
    {UcxChat.Robot.Responders.Hello, []},

    {HedwigSimpleResponders.Slogan, []},
    {HedwigSimpleResponders.ShipIt, %{ extra_squirrels: false }},
    {HedwigSimpleResponders.Time, []},
    {HedwigSimpleResponders.Uptime, []},
    {HedwigSimpleResponders.BeerMe, []},
    {HedwigSimpleResponders.Fishpun, []},
    {HedwigSimpleResponders.Slime, []},
    {HedwigSimpleResponders.Slogan, []},
  ]


# General application configuration
config :ucx_chat,
  ecto_repos: [UcxChat.Repo], generators: [binary_id: true]

# Configures the endpoint
config :ucx_chat, UcxChat.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6nkfr7ykCVhOrbxlY7JByCMkqkRf+JmH9UCMjB41RMOyc5qeFwMTtaMymWClbom2",
  render_errors: [view: UcxChat.ErrorView, accepts: ~w(html json)],
  pubsub: [name: UcxChat.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :template_engines,
  haml: PhoenixHaml.Engine

config :ucx_chat,
  page_size: 150,
  defer: true,
  emoji_one: [
    # single_class: "big",
    ascii: true,
    wrapper: :span,
    id_class: "emojione-"
    # src_path: "/images",
    # src_version: "?v=2.2.7",
    # img_type: ".png"
  ]

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: UcxChat.User,
  repo: UcxChat.Repo,
  module: UcxChat,
  login_field: :username,
  user_token: true,
  use_binary_id: true,
  logged_out_url: "/",
  layout: {Coherence.LayoutView, "app.html"},
  unlock_timeout_minutes: 5,
  require_current_password: false,
  email_from_name: {:system, "COH_NAME"},
  email_from_email: {:system, "COH_EMAIL"},
  opts: [:registerable, :invitable, :unlockable_with_token, :recoverable, :lockable, :authenticatable, :trackable]

config :coherence, UcxChat.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: {:system, "SENDGRID_API_KEY"}
# %% End Coherence Configuration %%

import_config "#{Mix.env}.exs"
