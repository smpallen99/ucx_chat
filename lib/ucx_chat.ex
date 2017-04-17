defmodule UcxChat do
  use Application

  @env Mix.env()

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(UcxChat.Repo, []),
      # Start the endpoint when the application starts
      supervisor(UcxChat.Endpoint, []),
      supervisor(UcxChat.Presence, []),
      worker(UcxChat.TypingAgent, []),
      worker(UcxChat.MessageAgent, []),
      worker(UcxChat.UserAgent, []),
      worker(UcxChat.PresenceAgent, []),
      # worker(UcxChat.Robot.Adapters.UcxChat, []),
      worker(UcxChat.Robot, []),
      worker(UcxChat.ChannelMonitor, [:chan_system]),
    ]
    UcxChat.Permission.startup
    UcxChat.Permission.init
    # Ucx.Dets.open_file
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UcxChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    UcxChat.Endpoint.config_change(changed, removed)
    :ok
  end

  def env, do: @env
end
