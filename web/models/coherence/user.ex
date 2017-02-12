defmodule UcxChat.User do
  @moduledoc false
  use UcxChat.Web, :model
  use Coherence.Schema

  schema "users" do
    field :name, :string
    field :email, :string
    field :username, :string
    field :admin, :boolean, default: false
    belongs_to :client, UcxChat.Client
    coherence_schema()

    timestamps()
  end
  @all_params ~w(name email username admin client_id)a
  @required  ~w(name email username)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_params ++ coherence_fields())
    |> validate_required(@required)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:username)
    |> validate_coherence(params)
  end
end
