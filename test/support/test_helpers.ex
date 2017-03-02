defmodule UcxChat.TestHelpers do
  alias UcxChat.{Repo, User, Channel, Account, Client, Subscription}
  alias FakerElixir, as: Faker
  use Hound.Helpers

  @channel_names ~w(general marketing sales research human_resources ucx leadership hospitality support social news updates ucx_chat notifier wall_board partners licensing remote_support)

  def insert_channel(owner, attrs \\ %{})
  def insert_channel(%User{} = user, attrs),
    do: insert_channel(user.client_id, attrs)
  def insert_channel(%Client{} = client, attrs),
    do: insert_channel(client.id, attrs)

  def insert_channel(client_id, attrs) when is_integer(client_id) do
    changes = Map.merge(%{
      client_id: client_id,
      name: FakerElixir.Helper.cycle(:channel_names, @channel_names)
    }, to_map(attrs))

    %Channel{}
    |> Channel.changeset(changes)
    |> Repo.insert!
  end


  def insert_subscription(attrs \\ %{})
  def insert_subscription(attrs) do
    user = insert_client_user attrs
    insert_subscription(user, insert_channel(user))
  end
  def insert_subscription(%User{} = user, %Channel{} = channel) do
    insert_subscription(user.client.id, channel.id)
  end
  def insert_subscription(%Client{} = client, %Channel{} = channel) do
    insert_subscription(client.id, channel.id)
  end
  def insert_subscription(client_id, channel_id)
    when is_integer(client_id) and is_integer(channel_id) do
    changes = %{
      open: true,
      client_id: client_id,
      channel_id: channel_id
    }
    %Subscription{}
    |> Subscription.changeset(changes)
    |> Repo.insert!
    |> Repo.preload([:channel, {:client, :user}])
  end

  def insert_client_user(attrs \\ %{}) do
    attrs
    |> insert_client
    |> insert_user
    |> Repo.preload([:client, :account])
  end

  def insert_client(attrs \\ %{}) do
    changes = Map.merge(%{
      nickname: Faker.Internet.user_name,
      }, to_map(attrs))
    Client.changeset(%Client{}, changes)
    |> Repo.insert!()
  end

  def insert_user(client, attrs \\ %{})
  def insert_user(%Client{id: id}, attrs) do
    insert_user(id, attrs)
  end

  def insert_user(client_id, attrs) do
    account = Account.changeset(%Account{}, %{}) |> Repo.insert!
    changes = Map.merge(%{
      name: Faker.Name.name,
      account_id: account.id,
      username: Faker.Internet.user_name,
      email: Faker.Internet.email,
      password: "secret",
      password_confirmation: "secret",
      client_id: client_id,
      }, to_map(attrs))
    User.changeset(%User{}, changes)
    |> Repo.insert!()
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
