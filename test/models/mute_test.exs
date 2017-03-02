defmodule UcxChat.MuteTest do
  use UcxChat.ModelCase

  alias UcxChat.Mute

  @valid_attrs %{user_id: 1, channel_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Mute.changeset(%Mute{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Mute.changeset(%Mute{}, @invalid_attrs)
    refute changeset.valid?
  end
end
