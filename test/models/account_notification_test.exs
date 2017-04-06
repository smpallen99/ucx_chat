defmodule UcxChat.AccountNotificationTest do
  use UcxChat.ModelCase

  alias UcxChat.AccountNotification

  @valid_attrs %{account_id: "sdfsdf", notification_id: "sdfsdfsdf"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = AccountNotification.changeset(%AccountNotification{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = AccountNotification.changeset(%AccountNotification{}, @invalid_attrs)
    refute changeset.valid?
  end
end
