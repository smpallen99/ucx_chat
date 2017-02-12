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

alias UcxChat.{Repo, Client, User}

Repo.delete_all UcxChat.User
Repo.delete_all Client

c1 = Client.changeset(%Client{}, %{nickname: "Admin"}) |> UcxChat.Repo.insert!
c2 = Client.changeset(%Client{}, %{nickname: "Steve"}) |> UcxChat.Repo.insert!

User.changeset(%User{}, %{client_id: c1.id, name: "Admin", email: "steve.pallen@emetrotel.com", username: "admin", password: "test123", password_confirmation: "test123", admin: true})
|> Repo.insert!

User.changeset(%User{}, %{client_id: c2.id, name: "Steve Pallen", email: "smpallen99@gmail.com", username: "spallen", password: "test123", password_confirmation: "test123"})
|> Repo.insert!

ChatChannel.changeset(%ChatChannel{}, %{name: "general"})
|> Repo.insert!
