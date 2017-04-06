defmodule UcxChat.TestHelpers do
  alias UcxChat.{Repo, User, Channel, Account, User, Subscription, ChannelService, UserRole}
  alias FakerElixir, as: Faker
  use Hound.Helpers

  @channel_names ~w(general marketing sales research human_resources ucx leadership hospitality support social news updates ucx_chat notifier wall_board partners licensing remote_support)

  def insert_channel(owner, attrs \\ %{})
  def insert_channel(%User{} = user, attrs),
    do: insert_channel(user.id, attrs)

  def insert_channel(user_id, attrs) do
    changes = Map.merge(%{
      user_id: user_id,
      name: FakerElixir.Helper.cycle(:channel_names, @channel_names)
    }, to_map(attrs))

    ChannelService.insert_channel(changes) |> elem(1)
  end


  def insert_subscription(attrs \\ %{})
  def insert_subscription(attrs) do
    user = insert_user attrs
    insert_subscription(user, insert_channel(user))
  end
  def insert_subscription(%User{} = user, %Channel{} = channel) do
    insert_subscription(user.id, channel.id)
  end
  def insert_subscription(user_id, channel_id) do
    changes = %{
      open: true,
      user_id: user_id,
      channel_id: channel_id
    }
    %Subscription{}
    |> Subscription.changeset(changes)
    |> Repo.insert!
    |> Repo.preload([:channel, :user])
  end

  def insert_user(attrs \\ %{})
  def insert_user(attrs) do
    account = Account.changeset(%Account{}, %{}) |> Repo.insert!
    changes = Map.merge(%{
      name: Faker.Name.name,
      account_id: account.id,
      username: Faker.Internet.user_name,
      email: Faker.Internet.email,
      password: "secret",
      password_confirmation: "secret",
      }, to_map(attrs))
    user =
      User.changeset(%User{}, changes)
      |> Repo.insert!()
    %UserRole{}
    |> UserRole.changeset(%{user_id: user.id, role: "user"})
    |> Repo.insert!
    Repo.preload user, [:account, :roles]
  end

  def site_url, do: "http://localhost:4099"

  def login_user(user) do
    navigate_to site_url()
    username_field = find_element(:name, "session[username]")
    password_field = find_element(:name, "session[password]")
    submit = find_element(:class, "btn-primary")
    fill_field username_field, user.username
    fill_field password_field, "secret"
    click submit
  end


  defp to_map(attrs) when is_list(attrs), do: Enum.into(attrs, %{})
  defp to_map(attrs), do: attrs
end
