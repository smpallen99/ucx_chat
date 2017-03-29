defmodule UcxChat.Mixfile do
  use Mix.Project

  @version "0.1.2"

  def project do
    [app: :ucx_chat,
     version: @version,
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     preferred_cli_env: [
                          coveralls: :test,
                          "coveralls.detail": :test,
                          "coveralls.html": :test,
                          "coveralls.post": :test,
                          commit: :test,
                          itest: :test,
                          credo: :test
                        ],
     test_coverage: [tool: ExCoveralls],
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {UcxChat, []},
     applications: applications(Mix.env())]

  end

  def applications(:prod), do: [
    :phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
    :phoenix_ecto, :mariaex, :coherence, :phoenix_haml, :hound, :syslog,
    :link_preview, :html_entities, :mogrify, :tempfile, :auto_linker,
  ]
  def applications(_), do: applications(:prod) ++ [:faker_elixir_octopus]


  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.1"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:mariaex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:phoenix_haml, "~> 0.2"},
     {:coherence, github: "smpallen99/coherence"},
     # {:coherence, path: "../coherence_channels"},
     {:ex_machina, "~> 1.0.2", only: :test},
     {:excoveralls, "~> 0.5.1", only: :test, app: false},
     {:faker_elixir_octopus, "~> 0.12.0", only: [:dev, :test]},
     {:hound, "~> 1.0"},
     {:distillery, "~> 1.2"},
     {:hackney, "~> 1.7.1", override: true},
     {:syslog, github: "smpallen99/syslog"},

     {:link_preview, "~> 1.0.0"},
     {:html_entities, "~> 0.2"},
     {:mogrify, "~> 0.4.0"},
     {:tempfile, "~> 0.1.0"},
     {:auto_linker, "~> 0.1"},
     # {:auto_linker, path: "../auto_linker"},

     {:cowboy, "~> 1.0", override: true}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"],
      commit: ["deps.get --only #{Mix.env}", "coveralls.html", "credo --strict"]
    ]
  end
end
