defmodule UcxChat.Permission do
  @moduledoc """
  Permissions management.

  Permissions are managed with an ets table that is sync'ed to the
  h/d when changes are made. The frequency of changes should be pretty
  low since that is only done through the admin GUI.

  TODO: Still need to implement the disk persistence part!!

  NOTE: This has been redesigned in the vew version
  """

  @default_permissions  [
    %{name: "access-permissions",            roles: ["admin"] },
    %{name: "add-oauth-service",             roles: ["admin"] },
    %{name: "add-user-to-joined-room",       roles: ["admin", "owner", "moderator"] },
    %{name: "add-user-to-any-c-room",        roles: ["admin"] },
    %{name: "add-user-to-any-p-room",        roles: [] },
    %{name: "archive-room",                  roles: ["admin", "owner"] },
    %{name: "assign-admin-role",             roles: ["admin"] },
    %{name: "ban-user",                      roles: ["admin", "owner", "moderator"] },
    %{name: "bulk-create-c",                 roles: ["admin"] },
    %{name: "bulk-register-user",            roles: ["admin"] },
    %{name: "create-c",                      roles: ["admin", "user", "bot"] },
    %{name: "create-d",                      roles: ["admin", "user", "bot"] },
    %{name: "create-p",                      roles: ["admin", "user", "bot"] },
    %{name: "create-user",                   roles: ["admin"] },
    %{name: "clean-channel-history",         roles: ["admin"] },
    %{name: "delete-c",                      roles: ["admin"] },
    %{name: "delete-d",                      roles: ["admin"] },
    %{name: "delete-message",                roles: ["admin", "owner", "moderator"] },
    %{name: "delete-p",                      roles: ["admin"] },
    %{name: "delete-user",                   roles: ["admin"] },
    %{name: "edit-message",                  roles: ["admin", "owner", "moderator"] },
    %{name: "edit-other-user-active-status", roles: ["admin"] },
    %{name: "edit-other-user-info",          roles: ["admin"] },
    %{name: "edit-other-user-password",      roles: ["admin"] },
    %{name: "edit-privileged-setting",       roles: ["admin"] },
    %{name: "edit-room",                     roles: ["admin", "owner", "moderator"] },
    %{name: "manage-assets",                 roles: ["admin"] },
    %{name: "manage-emoji",                  roles: ["admin"] },
    %{name: "manage-integrations",           roles: ["admin"] },
    %{name: "manage-own-integrations",       roles: ["admin", "bot"] },
    %{name: "manage-oauth-apps",             roles: ["admin"] },
    %{name: "mention-all",                   roles: ["admin", "owner", "moderator", "user"] },
    %{name: "mute-user",                     roles: ["admin", "owner", "moderator"] },
    %{name: "remove-user",                   roles: ["admin", "owner", "moderator"] },
    %{name: "run-import",                    roles: ["admin"] },
    %{name: "run-migration",                 roles: ["admin"] },
    %{name: "set-moderator",                 roles: ["admin", "owner"] },
    %{name: "set-owner",                     roles: ["admin", "owner"] },
    %{name: "unarchive-room",                roles: ["admin"] },
    %{name: "view-c-room",                   roles: ["admin", "user", "bot"] },
    %{name: "view-d-room",                   roles: ["admin", "user", "bot"] },
    %{name: "view-full-other-user-info",     roles: ["admin"] },
    %{name: "view-history",                  roles: ["admin", "user"] },
    %{name: "view-joined-room",              roles: ["guest", "bot"] },
    %{name: "view-join-code",                roles: ["admin"] },
    %{name: "view-logs",                     roles: ["admin"] },
    %{name: "view-other-user-channels",      roles: ["admin"] },
    %{name: "view-p-room",                   roles: ["admin", "user"] },
    %{name: "view-privileged-setting",       roles: ["admin"] },
    %{name: "view-room-administration",      roles: ["admin"] },
    %{name: "view-message-administration",   roles: ["admin"] },
    %{name: "view-statistics",               roles: ["admin"] },
    %{name: "view-user-administration",      roles: ["admin"] },
    %{name: "preview-c-room",                roles: ["admin", "user"] }
  ]

  @perms_key :permissions
  @table_name :perms

  def startup do
    :ets.new :perms, [:bag, :named_table, :public]
  end

  def init do
    @default_permissions
    |> Enum.each(fn %{name: name, roles: roles} ->
      Enum.each roles, fn role ->
        insert {@perms_key, name, role}
      end
    end)
  end

  def all do
    match({@perms_key, :"$1", :"$2"})
    |> Enum.reduce(%{}, fn [perms, role], acc ->
      update_in acc, [perms], fn
        nil -> [role]
        list -> [role|list]
      end
    end)
    |> Map.to_list
    |> Enum.sort
  end

  def has_permission?(user, permission, scope \\ nil) do
    permissions = match({@perms_key, permission, :"$1"})
    |> List.flatten
    Map.get(user, :roles)
    |> Enum.any?(fn %{role: name, scope: value} -> name in permissions and (value == nil or value == scope) end)
  end

  def has_at_least_one_permission?(user, list) do
    Enum.any? list, &has_permission?(user, &1)
  end
  def add_role_to_permission(permission, role) do
    insert {@perms_key, permission, role}
  end
  def remove_role_from_permission(permission, role) do
    delete_match {@perms_key, permission, role}
  end

  def room_type(0), do: "c"
  def room_type(1), do: "p"
  def room_type(2), do: "d"

  defp insert(tuple) do
    :ets.insert @table_name, tuple
  end

  defp match(tuple) do
    :ets.match @table_name, tuple
  end

  defp delete_match(tuple) do
    :ets.match_delete @table_name, tuple
  end

end
