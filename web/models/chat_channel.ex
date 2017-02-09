defmodule UcxChat.ChatChannel do
  use UcxChat.Web, :model

  schema "channels" do
    field :name, :string
    field :private, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :private])
    |> validate_required([:name, :private])
  end
end
