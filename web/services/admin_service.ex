defmodule UcxChat.AdminService do
  use UcxChat.Web, :service
  alias UcxChat.{Message, Channel, User}
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

  def handle_in("save:layout", params, socket) do
    params =
      params
      |> Helpers.normalize_form_params
      |> Map.get("layout")

    resp =
      Config
      |> Repo.one
      |> Config.changeset(%{layout: params})
      |> Repo.update
      |> case do
        {:ok, _} ->
          {:ok, %{success: "Layout settings updated successfully"}}
        {:error, cs} ->
          Logger.error "problem updating Layout settings: #{inspect cs}"
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

  def render_info(user) do
    render(AdminView, "info", "info.html")
  end

  defp get_args("permissions", user) do
    roles = Repo.all Role
    permissions = Permission.all

    [user: user, roles: roles, permissions: permissions]
  end
  defp get_args(view, user) when view in ~w(general message layout) do
    view_a = String.to_atom view
    mod = Module.concat Config, String.capitalize(view)
    cs =
      Config
      |> Repo.one
      |> Map.get(view_a)
      |> mod.changeset(%{})
    [user: user, changeset: cs]
  end
  # defp get_args("message", user) do
  #   cs =
  #     Config
  #     |> Repo.one
  #     |> Map.get(:message)
  #     |> Config.Message.changeset(%{})
  #   [user: user, changeset: cs]
  # end
  defp get_args("info", user) do
    total = User.total_count() |> Repo.one
    online = Agent.get(Coherence.CredentialStore.Agent, &(&1)) |> Map.keys |> length

    usage = [
      %{title: ~g"Total Users", value: total},
      %{title: ~g"Online Users", value: online},
      %{title: ~g"Offline Users", value: total - online},
      %{title: ~g"Total Rooms", value: Channel.total_rooms() |> Repo.one},
      %{title: ~g"Total Channels", value: Channel.total_channels() |> Repo.one},
      %{title: ~g"Total Private Groups", value: Channel.total_private() |> Repo.one},
      %{title: ~g"Total Direct Message Rooms", value: Channel.total_direct() |> Repo.one},
      %{title: ~g"Total Messages", value: Message.total_count() |> Repo.one},
      %{title: ~g"Total Messages in Channels", value: Message.total_channels() |> Repo.one},
      %{title: ~g"Total in Private Groups", value: Message.total_private() |> Repo.one},
      %{title: ~g"Total in Direct Messages", value: Message.total_direct() |> Repo.one},
    ]

    info = [usage: usage]

    [user: user, info: info]
  end
end
