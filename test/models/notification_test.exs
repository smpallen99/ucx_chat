defmodule UcxChat.NotificationTest do
  use UcxChat.ModelCase

  alias UcxChat.Notification

  @valid_attrs %{settings: %{}, channel_id: "sdf"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Notification.changeset(%Notification{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Notification.changeset(%Notification{}, @invalid_attrs)
    refute changeset.valid?
  end
end
