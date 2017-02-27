defmodule UcxChat.UserRole do
  use UcxChat.Web, :model

  schema "users_roles" do
    field :role, :string
    field :scope, :integer, default: 0
    belongs_to :user, UcxChat.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:role, :scope, :user_id])
    |> validate_required([:role])
  end
end
