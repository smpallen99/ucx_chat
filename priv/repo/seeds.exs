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

UcxChat.Repo.delete_all UcxChat.User

UcxChat.User.changeset(%UcxChat.User{}, %{name: "Admin", email: "steve.pallen@emetrotel.com", username: "admin", password: "test123", password_confirmation: "test123", admin: true})
|> UcxChat.Repo.insert!

UcxChat.User.changeset(%UcxChat.User{}, %{name: "Steve Pallen", email: "smpallen99@gmail.com", username: "spallen", password: "test123", password_confirmation: "test123"})
|> UcxChat.Repo.insert!
