defmodule UcxChat.AdminService do
  use UcxChat.Web, :service

  require Logger

  alias UcxChat.{Permission, Role, AdminView, Config}

  def handle_in("save:general", params, socket) do
    params =
      params
      |> Helpers.normalize_form_params
      |> Map.get("general")
      |> do_slash_commands_params("chat_slash_commands")
      |> do_slash_commands_params("rooms_slash_commands")

    resp =
      Config
      |> Repo.one
      |> Config.changeset(%{general: params})
      |> Repo.update
      |> case do
        {:ok, _} ->
          {:ok, %{success: "General settings updated successfully"}}
        {:error, cs} ->
          Logger.error "problem updating general: #{inspect cs}"
          {:ok, %{error: "There a problem updating your settings."}}
      end
    {:reply, resp, socket}
  end

  def handle_in("save:message", params, socket) do
    params =
      params
      |> Helpers.normalize_form_params
      |> Map.get("message")

    resp =
      Config
      |> Repo.one
      |> Config.changeset(%{message: params})
      |> Repo.update
      |> case do
        {:ok, _} ->
          {:ok, %{success: "Message settings updated successfully"}}
        {:error, cs} ->
          Logger.error "problem updating Message settings: #{inspect cs}"
          {:ok, %{error: "There a problem updating your settings."}}
      end
    {:reply, resp, socket}
  end

  def do_slash_commands_params(params, which) do
    slash_commands =
      params
      |> Map.get(which, [])
      |> Enum.reduce([], fn
        {opt, "on"}, acc -> [opt|acc]
        _, acc -> acc
      end)

    put_in(params, [which], slash_commands)
  end

  def render(user, link, templ) do
    Helpers.render(AdminView, templ, get_args(link, user))
  end

  defp get_args("permissions", user) do
    roles = Repo.all Role
    permissions = Permission.all

    [user: user, roles: roles, permissions: permissions]
  end
  defp get_args("general", user) do
    cs =
      Config
      |> Repo.one
      |> Map.get(:general)
      |> Config.General.changeset(%{})
    [user: user, changeset: cs]
  end
  defp get_args("message", user) do
    cs =
      Config
      |> Repo.one
      |> Map.get(:message)
      |> Config.Message.changeset(%{})
    [user: user, changeset: cs]
  end
end
