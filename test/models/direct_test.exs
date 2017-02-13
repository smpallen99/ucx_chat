defmodule UcxChat.DirectTest do
  use UcxChat.ModelCase

  alias UcxChat.Direct

  @valid_attrs %{users: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Direct.changeset(%Direct{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Direct.changeset(%Direct{}, @invalid_attrs)
    refute changeset.valid?
  end
end
