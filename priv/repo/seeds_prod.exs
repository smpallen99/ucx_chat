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

u0 = create_user.("Bot", "bot@example.com", "test", :bot)
u1 = create_user.("Admin", "admin@spallen.com", "test", true)

ch1 = ChannelService.insert_channel!(%{name: "general", user_id: u1.id, default: true})

[ch1]
|> Enum.each(fn ch ->
  %Subscription{}
  |> Subscription.changeset(%{channel_id: ch.id, user_id: u1.id})
  |> Repo.insert!
end)
