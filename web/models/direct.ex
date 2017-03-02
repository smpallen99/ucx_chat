defmodule UcxChat.Direct do
  use UcxChat.Web, :model

  schema "directs" do
    field :users, :string
    belongs_to :user, UcxChat.User
    belongs_to :channel, UcxChat.Channel

    timestamps(type: :utc_datetime)
  end

  @fields ~w(users user_id channel_id)a
  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:users, name: :directs_user_id_users_index)
  end
end
