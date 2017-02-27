defmodule UcxChat.Role do
  use UcxChat.Web, :model

  @primary_key {:name, :string, autogenerate: false}

  schema "roles" do
    field :scope, :string, default: "global"
    field :description, :string

    timestamps()
  end

  @scopes ~w(global rooms)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :scope, :description])
    |> validate_required([:name])
    |> validate_inclusion(:scope, @scopes)
    |> unique_constraint(:name)
  end
end
