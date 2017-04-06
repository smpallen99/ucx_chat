defmodule UcxChat.SubscriptionTest do
  use UcxChat.ModelCase

  alias UcxChat.Subscription

  @valid_attrs %{
    user_id: "sdf", channel_id: "sdfdf", last_read: "sdf", type: 0,
    open: true, alert: true, hidden: false, has_unread: false, f: false,
    current_message: "sdf", unread: 0
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Subscription.changeset(%Subscription{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Subscription.changeset(%Subscription{}, @invalid_attrs)
    refute changeset.valid?
  end
end
