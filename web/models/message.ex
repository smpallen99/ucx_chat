defmodule UcxChat.Message do
  use UcxChat.Web, :model

  schema "messages" do
    field :body, :string
    field :sequential, :boolean, default: false
    belongs_to :client, UcxChat.Client
    belongs_to :channel, UcxChat.Channel

    field :is_groupable, :boolean, virtual: true
    field :system, :string, virtual: true
    field :t, :string, virtual: true
    field :own :boolean, virtual: true
    field :is_temp :boolean, virtual: true
    field :chat_opts :boolean, virtual: true
    field :custom_class :string, virtual: true
    field :avatar, :string, virtual: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :client_id, :channel_id, :sequential])
    |> validate_required([:body, :client_id])
  end
end
