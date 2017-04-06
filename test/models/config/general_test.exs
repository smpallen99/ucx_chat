defmodule UcxChat.ConfigGeneralTest do
  use UcxChat.ModelCase
  alias UcxChat.{Config.General}

  @valid_attrs %{enable_favorate_rooms: true, rooms_slash_commands: ["one"], chat_slash_commands: ["two"]}
  # @invalid_attrs %{}

  test "valid attributes" do
    changeset = General.changeset(%General{}, @valid_attrs)
    assert changeset.valid?
  end

  # test "invalid attributes" do
  #   changeset = General.changeset(%General{}, @invalid_attrs)
  #   refute changeset.valid?
  # end

end
