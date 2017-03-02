defmodule UcxChat.Mute do
  use UcxChat.Web, :model

  schema "muted" do
    belongs_to :user, UcxChat.User
    belongs_to :channel, UcxChat.Channel

    timestamps()
  end

  @fields ~w(user_id channel_id)a
  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:user_id, name: :muted_user_id_channel_id_index)
  end
end
