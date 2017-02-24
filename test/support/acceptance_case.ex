defmodule UcxChat.AcceptanceCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Hound.Helpers

      import Ecto.Schema
      import Ecto.Query, only: [from: 2]

      alias UcxChat.Repo
      import UcxChat.Router.Helpers
      import UcxChat.TestHelpers
      import UcxChat.ErrorView
      import UcxChat.Factory
      @endpoint UcxChat.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(UcxChat.Repo)
    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(UcxChat.Repo, self())
    Hound.start_session(metadata: metadata)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(UcxChat.Repo, {:shared, self()})
    end
    :ok
  end
end

