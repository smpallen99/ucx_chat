# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     UcxChat.Repo.insert!(%UcxChat.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias UcxChat.{
  Repo, User, Channel, Subscription, Message, Account, Mention,
  Direct, PinnedMessage, StaredMessage, Config, Role, UserRole,
  ChannelService, Attachment, Reaction
}

Repo.delete_all UserRole
Repo.delete_all User
Repo.delete_all Reaction
Repo.delete_all Attachment
Repo.delete_all Account
Repo.delete_all Channel
Repo.delete_all Subscription
Repo.delete_all Mention
Repo.delete_all Direct
Repo.delete_all Message
Repo.delete_all PinnedMessage
Repo.delete_all StaredMessage
Repo.delete_all Config
Repo.delete_all Role


Repo.insert! Config.new_changeset

roles =
  [admin: :global, moderator: :rooms, owner: :rooms, user: :global, bot: :global, guest: :global]
  |> Enum.map(fn {role, scope} ->
    %Role{}
    |> Role.changeset(%{name: to_string(role), scope: to_string(scope)})
    |> Repo.insert!
  end)

create_username = fn name ->
  name
  |> String.downcase
  |> String.split(" ", trim: true)
  |> Enum.join(".")
end

create_user = fn name, email, password, admin ->
  username = create_username.(name)
  account = %Account{} |> Account.changeset(%{}) |> Repo.insert!
  params = %{
    username: username, account_id: account.id, name: name, email: email,
    password: password, password_confirmation: password
  }
  params = if admin == :bot, do: Map.put(params, :avatar_url, "/images/hubot.png"), else: params
  user =
    %User{}
    |> User.changeset(params)
    |> Repo.insert!
  role_name = case admin do
    true -> "admin"
    false -> "user"
    :bot -> "bot"
  end

  %UserRole{}
  |> UserRole.changeset(%{user_id: user.id, role: role_name})
  |> Repo.insert!

  user
end


# c1 = User.changeset(%User{}, %{nickname: "Admin"}) |> UcxChat.Repo.insert!
# c2 = User.changeset(%User{}, %{nickname: "Steve"}) |> UcxChat.Repo.insert!
# c3 = User.changeset(%User{}, %{nickname: "Merilee"}) |> UcxChat.Repo.insert!

# u0 = User.changeset(%User{}, %{name: "UCxBot", username: "UCxBot", type: "b"}) |> UcxChat.Repo.insert!
u0 = create_user.("Bot", "bot@example.com", "test", :bot)
u1 = create_user.("Admin", "admin@spallen.com", "test", true)
u2 = create_user.("Steve Pallen", "steve.pallen@spallen.com", "test", true)
u3 = create_user.("Merilee Lackey", "merilee.lackey@spallen.com", "test", false)

users =
  [
    "Jamie Pallen", "Jason Pallen", "Simon", "Eric", "Lina", "Denine", "Vince", "Richard", "Sharron",
    "Ardavan", "Joseph", "Chris", "Osmond", "Patrick", "Tom", "Jeff"
  ]
  |> Enum.map(fn name ->
    lname = create_username.(name)
    create_user.(name, "#{lname}@example.com", "test", false)
  end)


ch1 = ChannelService.insert_channel!(%{name: "general", user_id: u0.id})
ch2 = ChannelService.insert_channel!(%{name: "support", user_id: u1.id})

channels =
  ~w(Research Marketing HR Accounting Shipping Sales) ++ ["UCxWebUser", "UCxChat"]
  |> Enum.map(fn name ->
    ChannelService.insert_channel!(%{name: name, user_id: u1.id})
  end)

[ch1, ch2] ++ Enum.take(channels, 3)
|> Enum.each(fn ch ->
  %Subscription{}
  |> Subscription.changeset(%{channel_id: ch.id, user_id: u1.id})
  |> Repo.insert!
  %Subscription{}
  |> Subscription.changeset(%{channel_id: ch.id, user_id: u2.id})
  |> Repo.insert!
  %Subscription{}
  |> Subscription.changeset(%{channel_id: ch.id, user_id: u3.id})
  |> Repo.insert!
end)


users
|> Enum.each(fn c ->
  %Subscription{}
  |> Subscription.changeset(%{channel_id: ch1.id, user_id: c.id})
  |> Repo.insert!
end)

chan_parts = ~w(biz sales tech foo home work product pbx phone iphone galaxy android slim user small big sand storm snow rain tv shows earth hail)
for i <- 1..50 do
  name = Enum.random(chan_parts) <> to_string(i) <> Enum.random(chan_parts)
  user = Enum.random(users)
  ChannelService.insert_channel!(%{name: name, user_id: user.id})
end

add_messages = true

if add_messages do
  messages = [
    "hello there",
    "what's up doc",
    "are you there?",
    "Did you get the join?",
    "When will you be home?",
    "Be right there!",
    "Can't wait to see you!",
    "What did you watch last night?",
    "Is your homework done yet?",
    "what time is it?",
    "whats for dinner?",
    "are you sleeping?",
    "how did you sleep last night?",
    "did you have a good trip?",
    "Tell me about your day",
    "be home by 5 please",
    "wake me up a 9 please",
    "ttyl",
    "cul8r",
    "hope it works",
    "Let me tell you a story about a man named Jed",
  ]

  user_ids = [u1.id, u2.id, u3.id]
  other_ch_ids = Enum.take(channels, 3) |> Enum.map(&(&1.id))
  for _ <- 0..500 do
    for ch_id <- [ch1.id, ch2.id] ++ other_ch_ids do
      id = Enum.random user_ids
      %Message{}
      |> Message.changeset(%{channel_id: ch_id, user_id: id, body: Enum.random(messages)})
      |> Repo.insert!
    end
  end

  for _ <- 0..500 do
    id = Enum.random user_ids
    %Message{}
    |> Message.changeset(%{channel_id: ch1.id, user_id: id, body: Enum.random(messages)})
    |> Repo.insert!
  end

  new_channel_users = [
    {Enum.random(users), Enum.random(channels)},
    {Enum.random(users), Enum.random(channels)},
    {Enum.random(users), Enum.random(channels)},
    {Enum.random(users), Enum.random(channels)},
    {Enum.random(users), Enum.random(channels)},
    {Enum.random(users), Enum.random(channels)},
    {Enum.random(users), Enum.random(channels)},
  ]

  new_channel_users
  |> Enum.each(fn {c, ch} ->
    %Subscription{}
    |> Subscription.changeset(%{channel_id: ch.id, user_id: c.id})
    |> Repo.insert!
  end)

  for _ <- 1..200 do
    {c, ch} = Enum.random new_channel_users
    %Message{}
    |> Message.changeset(%{channel_id: ch.id, user_id: c.id, body: Enum.random(messages)})
    |> Repo.insert!
  end
end
