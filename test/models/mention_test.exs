defmodule UcxChat.MentionTest do
  use UcxChat.ModelCase

  alias UcxChat.Mention

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Mention.changeset(%Mention{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Mention.changeset(%Mention{}, @invalid_attrs)
    refute changeset.valid?
  end
end
