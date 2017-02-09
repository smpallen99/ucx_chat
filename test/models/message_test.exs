defmodule UcxChat.MessageTest do
  use UcxChat.ModelCase

  alias UcxChat.Message

  @valid_attrs %{body: "some content", client_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Message.changeset(%Message{}, @invalid_attrs)
    refute changeset.valid?
  end
end
