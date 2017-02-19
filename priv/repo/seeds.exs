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

alias UcxChat.{Repo, Client, User, Channel, Subscription, Message}

Repo.delete_all User
Repo.delete_all Client

c0 = Client.changeset(%Client{}, %{nickname: "UCxBot", type: "b"}) |> UcxChat.Repo.insert!

c1 = Client.changeset(%Client{}, %{nickname: "Admin"}) |> UcxChat.Repo.insert!
c2 = Client.changeset(%Client{}, %{nickname: "Steve"}) |> UcxChat.Repo.insert!
c3 = Client.changeset(%Client{}, %{nickname: "Merilee"}) |> UcxChat.Repo.insert!

clients =
  [
    "Jamie", "Jason", "Simon", "Eric", "Lina", "Denine", "Vince", "Richard", "Sharron",
    "Ardavan", "Joseph", "Chris", "Osmond", "Patrick", "Tom", "Jeff"
  ]
  |> Enum.map(fn name ->
    c =
      %Client{}
      |> Client.changeset(%{nickname: name})
      |> UcxChat.Repo.insert!
    lname = String.downcase name
    %User{}
    |> User.changeset(%{client_id: c.id, name: name, email: "#{lname}@example.com",
        username: lname, password: "test", password_confirmation: "test", admin: false})
    |> Repo.insert!
    c
  end)
_u1 = User.changeset(%User{}, %{client_id: c1.id, name: "Admin", email: "steve.pallen@emetrotel.com", username: "admin", password: "test123", password_confirmation: "test123", admin: true})
|> Repo.insert!

_u2 = User.changeset(%User{}, %{client_id: c2.id, name: "Steve Pallen", email: "smpallen99@gmail.com", username: "spallen", password: "test123", password_confirmation: "test123"})
|> Repo.insert!

_u3 = User.changeset(%User{}, %{client_id: c3.id, name: "Merilee Lackey", email: "smpallen99@yahoo.com", username: "merilee", password: "test123", password_confirmation: "test123"})
|> Repo.insert!

ch1 = Channel.changeset(%Channel{}, %{name: "general", client_id: c0.id})
|> Repo.insert!
ch2 = Channel.changeset(%Channel{}, %{name: "support", client_id: c1.id})
|> Repo.insert!

channels =
  ~w(Research Marketing HR Accounting Shipping Sales) ++ ["UCx Web Client", "UCx Chat"]
  |> Enum.map(fn name ->
    Channel.changeset(%Channel{}, %{name: name, client_id: c1.id})
    |> Repo.insert!
  end)

[ch1, ch2] ++ Enum.take(channels, 3)
|> Enum.each(fn ch ->
  %Subscription{}
  |> Subscription.changeset(%{channel_id: ch.id, client_id: c1.id})
  |> Repo.insert!
  %Subscription{}
  |> Subscription.changeset(%{channel_id: ch.id, client_id: c2.id})
  |> Repo.insert!
  %Subscription{}
  |> Subscription.changeset(%{channel_id: ch.id, client_id: c3.id})
  |> Repo.insert!
end)


clients
|> Enum.each(fn c ->
  %Subscription{}
  |> Subscription.changeset(%{channel_id: ch1.id, client_id: c.id})
  |> Repo.insert!
end)

add_messages = false

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

  client_ids = [c1.id, c2.id, c3.id]
  other_ch_ids = Enum.take(channels, 3) |> Enum.map(&(&1.id))
  for _ <- 0..500 do
    for ch_id <- [ch1.id, ch2.id] ++ other_ch_ids do
      id = Enum.random client_ids
      %Message{}
      |> Message.changeset(%{channel_id: ch_id, client_id: id, body: Enum.random(messages)})
      |> Repo.insert!
    end
  end

  new_channel_clients = [
    {Enum.random(clients), Enum.random(channels)},
    {Enum.random(clients), Enum.random(channels)},
    {Enum.random(clients), Enum.random(channels)},
    {Enum.random(clients), Enum.random(channels)},
    {Enum.random(clients), Enum.random(channels)},
    {Enum.random(clients), Enum.random(channels)},
    {Enum.random(clients), Enum.random(channels)},
  ]

  new_channel_clients
  |> Enum.each(fn {c, ch} ->
    %Subscription{}
    |> Subscription.changeset(%{channel_id: ch.id, client_id: c.id})
    |> Repo.insert!
  end)

  for _ <- 1..200 do
    {c, ch} = Enum.random new_channel_clients
    %Message{}
    |> Message.changeset(%{channel_id: ch.id, client_id: c.id, body: Enum.random(messages)})
    |> Repo.insert!
  end
end
