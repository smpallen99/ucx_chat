defmodule UcxChat.AdminService do
  use UcxChat.Web, :service

  alias UcxChat.{Permission, Role, AdminView}

  def render(user, link, templ) do
    Helpers.render(AdminView, templ, get_args(link, user))
  end

  defp get_args("permissions", user) do
    roles = Repo.all Role
    permissions = Permission.all

    [user: user, roles: roles, permissions: permissions]
  end
end
