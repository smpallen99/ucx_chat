defmodule UcxChat.User do
  @moduledoc false
  use UcxChat.Web, :model
  use Coherence.Schema

  @mod __MODULE__

  schema "users" do
    field :name, :string
    field :email, :string
    field :username, :string
    field :admin, :boolean, default: false

    has_many :roles, UcxChat.UserRole

    belongs_to :client, UcxChat.Client
    belongs_to :account, UcxChat.Account
    coherence_schema()

    timestamps()
  end
  @all_params ~w(name email username admin client_id account_id)a
  @required  ~w(name email username account_id)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_params ++ coherence_fields())
    |> validate_required(@required)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:username)
    |> validate_coherence(params)
    |> cast_assoc(:roles)
  end

  def total_count do
    from u in @mod, select: count(u.id)
  end

end
