defmodule UcxChat.UserRoleTest do
  use UcxChat.ModelCase

  alias UcxChat.UserRole

  @valid_attrs %{role: "name", scope: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserRole.changeset(%UserRole{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserRole.changeset(%UserRole{}, @invalid_attrs)
    refute changeset.valid?
  end
end
