defmodule UcxChat.ReactionTest do
  use UcxChat.ModelCase

  alias UcxChat.Reaction

  @valid_attrs %{count: 42, emoji: "somecontent", users_ids: "adf", message_id: "sdf"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Reaction.changeset(%Reaction{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Reaction.changeset(%Reaction{}, @invalid_attrs)
    refute changeset.valid?
  end
end
