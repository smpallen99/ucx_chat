defmodule UcxChat.StaredMessageTest do
  use UcxChat.ModelCase

  alias UcxChat.StaredMessage

  @valid_attrs %{channel_id: 1, client_id: 1, message_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = StaredMessage.changeset(%StaredMessage{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = StaredMessage.changeset(%StaredMessage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
