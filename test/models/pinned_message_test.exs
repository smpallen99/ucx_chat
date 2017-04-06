defmodule UcxChat.PinnedMessageTest do
  use UcxChat.ModelCase

  alias UcxChat.PinnedMessage

  @valid_attrs %{message_id: "df", channel_id: "sdfd"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PinnedMessage.changeset(%PinnedMessage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PinnedMessage.changeset(%PinnedMessage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
