defmodule UcxChat.ConfigMessageTest do
  use UcxChat.ModelCase
  alias UcxChat.{Config.Message}

  @valid_attrs %{allow_message_editing: true, allow_message_deleting: false}
  @invalid_attrs %{}

  test "valid attributes" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert changeset.valid?
  end

  # test "invalid attributes" do
  #   changeset = Message.changeset(%Message{}, @invalid_attrs)
  #   refute changeset.valid?
  # end

end
