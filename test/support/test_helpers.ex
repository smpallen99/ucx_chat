defmodule UcxChat.TestHelpers do
  alias UcxChat.{Repo, User, Account, Client}
  alias FakerElixir, as: Faker
  use Hound.Helpers

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
