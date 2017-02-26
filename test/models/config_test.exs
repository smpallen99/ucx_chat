defmodule UcxChat.ConfigTest do
  use UcxChat.ModelCase

  alias UcxChat.{Config, Config.General, Config.Message}

  @general_attrs Map.from_struct(%General{})
  @message_attrs Map.from_struct(%Message{})

  @valid_attrs %{general: @general_attrs, message: @message_attrs}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Config.changeset(%Config{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Config.changeset(%Config{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "new changeset" do
    changeset = Config.new_changeset()
    assert changeset.valid?
  end
end
