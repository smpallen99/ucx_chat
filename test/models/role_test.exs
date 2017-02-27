defmodule UcxChat.RoleTest do
  use UcxChat.ModelCase

  alias UcxChat.Role

  @valid_attrs %{name: "some", scope: "global"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Role.changeset(%Role{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Role.changeset(%Role{}, @invalid_attrs)
    refute changeset.valid?
  end
end
