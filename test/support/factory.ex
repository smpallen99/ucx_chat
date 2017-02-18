defmodule UcxChat.Factory do
  use ExMachina.Ecto, repo: UcxChat.Repo

  alias UcxChat.{User, Client, Channel, Subscription, Mention, Message, PinnedMessage, StaredMessage, Direct}

  alias FakerElixir, as: Faker

  def basic_setup_factory do
    subs = build(:subscription)
    # for _ <- 0..4 do
    #   insert(:message, %{client_id: subs.client.id, channel_id: subs.channel.id})
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

  def client_factory do
    %Client{
      nickname: Faker.Internet.user_name,
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
      client: build(:client),
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
      # client: build(:client),
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
      # client: build(:client),
      # channel: build(:channel),
      # message: build(:message)
    }
  end
  def direct_factory do
    %Direct{
      client: build(:client),
      channel: build(:channel)
    }
  end

end
