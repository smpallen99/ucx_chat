{:ok, _} = Application.ensure_all_started(:ex_machina)
Application.ensure_all_started(:hound)
ExUnit.configure(timeout: :infinity)
ExUnit.configure(exclude: [pending: true, integration: true])

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(UcxChat.Repo, :manual)

