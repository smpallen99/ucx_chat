defmodule UcxChat.User do
  @moduledoc false
  use UcxChat.Web, :model
  use Coherence.Schema

  schema "chat_users" do
    field :name, :string
    field :email, :string
    field :username, :string
    field :chat_status, :string
    field :admin, :boolean, default: false
    field :tag_line
    coherence_schema()

    timestamps()
  end
  @all_params ~w(name email username chat_status admin tag_line)a
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
