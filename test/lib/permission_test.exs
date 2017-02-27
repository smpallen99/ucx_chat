defmodule UcxChat.PermissionTest do
  use ExUnit.Case
  import UcxChat.Permission

  setup do
    user1 = %{roles: [%{n: "admin", v: 0}, %{n: "moderator", v: 1}, %{n: "owner", v: 2}]}
    user2 = %{roles: [%{n: "user", v: 0}, %{n: "moderator", v: 2}, %{n: "owner", v: 4}]}
    {:ok, u1: user1, u2: user2}
  end

  test "has_permission?", %{u1: u1, u2: u2} do
    assert has_permission?(u1, "mute-user", 1)
    assert has_permission?(u1, "mute-user", 2)
    assert has_permission?(u1, "mute-user", 3)

    refute has_permission?(u2, "mute-user", 1)
    assert has_permission?(u2, "mute-user", 2)
    assert has_permission?(u2, "view-history", 3)
    assert has_permission?(u2, "set-moderator", 4)
    refute has_permission?(u2, "set-moderator", 3)
    refute has_permission?(u2, "set-moderator", 2)
  end

  test "add and delete roles", %{u1: _u1, u2: u2} do
    refute has_permission?(u2, "view-statistics", 0)

    add_role_to_permission("view-statistics", "owner")

    refute has_permission?(u2, "view-statistics", 0)
    assert has_permission?(u2, "view-statistics", 4)

    add_role_to_permission("view-statistics", "user")

    assert has_permission?(u2, "view-statistics", 0)

    remove_role_from_permission("view-statistics", "owner")
    remove_role_from_permission("view-statistics", "user")

    refute has_permission?(u2, "view-statistics", 0)
    refute has_permission?(u2, "view-statistics", 4)
  end

end
