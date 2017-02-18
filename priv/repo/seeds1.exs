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

alias UcxChat.{Repo, Client, User, Channel, Subscription}
require Ecto.Query

clients =
  [
    "Jamie", "Jason", "Simon", "Eric", "Lina", "Denine", "Vince", "Richard",
    "Sharron", "Ardavan", "Joseph", "Chris", "Osmond", "Patrick", "Tom", "Jeff"
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

ch1 = Channel |> Ecto.Query.first |> Repo.one!

clients
|> Enum.each(fn c ->
  %Subscription{}
  |> Subscription.changeset(%{channel_id: ch1.id, client_id: c.id})
  |> Repo.insert!
end)
