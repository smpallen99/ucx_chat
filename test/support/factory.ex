defmodule UcxChat.Factory do
  use ExMachina.Ecto, repo: UcxChat.Repo

  alias UcxChat.{User, Channel, Subscription, Mention, Message, PinnedMessage, StaredMessage, Direct}

  alias FakerElixir, as: Faker

  def basic_setup_factory do
    subs = build(:subscription)
    # for _ <- 0..4 do
    #   insert(:message, %{user_id: subs.user.id, channel_id: subs.channel.id})
    # end
    subs
  end

  def user_factory do
    %User{
      name: Faker.Name.name,
      username: Faker.Internet.user_name,
      email: Faker.Internet.email,
      password_hash: "changeme",
      password: "changeme",
      password_confirmation: "changeme",
    }
  end


  def channel_factory do
    %Channel{
      name: Faker.App.name,
      topic: Faker.Lorem.words(100)
    }
  end

  def subscription_factory do
    %Subscription{
      open: true,
      user: build(:user),
      channel: build(:channel)
    }
  end

  def message_factory do
    %Message{
      body: Faker.Lorem.words(25),
      sequential: false,
      timestamp: UcxChat.ServiceHelpers.get_timestamp()
    }
  end

  def mention_factory do
    %Mention{
      # user: build(:user),
      # channel: build(:channel),
      # message: build(:message)
    }
  end

  def pinned_message_factory do
    %PinnedMessage{
      # message: build(:message),
      # channel: build(:channel)
    }
  end
  def stared_message_factory do
    %StaredMessage{
      # user: build(:user),
      # channel: build(:channel),
      # message: build(:message)
    }
  end
  def direct_factory do
    %Direct{
      user: build(:user),
      channel: build(:channel)
    }
  end

end
