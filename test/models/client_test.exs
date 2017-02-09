defmodule UcxChat.ClientTest do
  use UcxChat.ModelCase

  alias UcxChat.Client

  @valid_attrs %{chat_status: "some content", nickname: "some content", tag_line: "some content", uri: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Client.changeset(%Client{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Client.changeset(%Client{}, @invalid_attrs)
    refute changeset.valid?
  end
end
