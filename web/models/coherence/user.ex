defmodule UcxChat.User do
  @moduledoc false
  use UcxChat.Web, :model
  use Coherence.Schema
  alias UcxChat.User

  @mod __MODULE__

  schema "users" do
    field :name, :string
    field :email, :string
    field :username, :string
    # field :admin, :boolean, default: false
    field :tz_offset, :integer
    field :alias, :string
    field :chat_status, :string
    field :tag_line, :string
    field :uri, :string
    field :status, :string, default: "offline", virtual: true

    belongs_to :open, UcxChat.Channel, foreign_key: :open_id

    has_many :roles, UcxChat.UserRole
    has_many :subscriptions, UcxChat.Subscription
    has_many :channels, through: [:subscriptions, :channel]
    has_many :messages, UcxChat.Message
    has_many :stared_messages, UcxChat.StaredMessage
    has_many :owns, UcxChat.Channel, foreign_key: :user_id

    belongs_to :account, UcxChat.Account
    coherence_schema()

    timestamps()
  end

  @all_params ~w(name email username account_id tz_offset alias chat_status tag_line uri open_id)a
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

  def user_id_and_username(user_id) do
    from u in @mod,
      where: u.id == ^user_id,
      select: {u.id, u.username}
  end
  def user_from_username(username) do
    from u in @mod,
      where: u.username == ^username
  end

  def display_name(%@mod{} = user) do
    user.alias || user.username
  end

  def all do
    from u in @mod
  end

  def tags(user, channel_id) do
    user.roles
    |> Enum.reduce([], fn
      %{role: role, scope: ^channel_id}, acc -> [role | acc]
      %{role: "user"}, acc -> acc
      %{role: role}, acc when role in ~w(bot guest admin) -> [role | acc]
      _, acc -> acc
    end)
    |> Enum.map(&String.capitalize/1)
    |> Enum.sort
  end
end
