defmodule UcxChat.PermissionTest do
  use ExUnit.Case
  import UcxChat.Permission

  setup do
    user1 = %{roles: [%{role: "admin", scope: nil}, %{role: "moderator", scope: "1"}, %{role: "owner", scope: "2"}]}
    user2 = %{roles: [%{role: "user", scope: nil %{role: "moderator", scope: "2"}, %{role: "owner", scope: "4"}]}
    {:ok, u1: user1, u2: user2}
  end

  test "has_permission?", %{u1: u1, u2: u2} do
    assert has_permission?(u1, "mute-user", "1")
    assert has_permission?(u1, "mute-user", "2")
    assert has_permission?(u1, "mute-user", "3")

    refute has_permission?(u2, "mute-user", "1")
    assert has_permission?(u2, "mute-user", "2")
    assert has_permission?(u2, "view-history", "3")
    assert has_permission?(u2, "set-moderator", "4")
    refute has_permission?(u2, "set-moderator", "3")
    refute has_permission?(u2, "set-moderator", "2")
  end

  test "add and delete roles", %{u1: _u1, u2: u2} do
    refute has_permission?(u2, "view-statistics", nil)

    add_role_to_permission("view-statistics", "owner")

    refute has_permission?(u2, "view-statistics", nil)
    assert has_permission?(u2, "view-statistics", "4")

    add_role_to_permission("view-statistics", "user")

    assert has_permission?(u2, "view-statistics", nil)

    remove_role_from_permission("view-statistics", "owner")
    remove_role_from_permission("view-statistics", "user")

    refute has_permission?(u2, "view-statistics", nil)
    refute has_permission?(u2, "view-statistics", "4")
  end

end
