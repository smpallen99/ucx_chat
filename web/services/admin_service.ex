defmodule UcxChat.AdminService do
  use UcxChat.Web, :service
  use UcxChat.ChannelApi

  alias UcxChat.{Message, Channel, User, UserService, FlexBarView, UserRole, AdminView}
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
          {:ok, %{success: ~g"General settings updated successfully"}}
        {:error, cs} ->
          Logger.error "problem updating general: #{inspect cs}"
          {:ok, %{error: ~g"There a problem updating your settings."}}
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
          {:ok, %{success: ~g"Message settings updated successfully"}}
        {:error, cs} ->
          Logger.error "problem updating Message settings: #{inspect cs}"
          {:ok, %{error: ~g"There a problem updating your settings."}}
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
          {:ok, %{success: ~g"Layout settings updated successfully"}}
        {:error, cs} ->
          Logger.error "problem updating Layout settings: #{inspect cs}"
          {:ok, %{error: ~g"There a problem updating your settings."}}
      end
    {:reply, resp, socket}
  end

  def handle_in(ev = "flex:user-info", %{"name" => name} = params, socket) do
    debug ev, params
    assigns = socket.assigns
    current_user = Helpers.get_user!(assigns.user_id)
    user = Helpers.get_by!(User, :username, name, preload: [:roles, :account])
    html =
      "user_card.html"
      |> FlexBarView.render(user: user, current_user: current_user, channel_id: 0, user_info: %{admin: true})
      |> safe_to_string

    {:reply, {:ok, %{html: html, title: "User Info"}}, socket}
  end

  def handle_in(ev = "flex:room-info", %{"name" => name} = params, socket) do
    debug ev, params
    assigns = socket.assigns
    current_user = Helpers.get_user!(assigns.user_id)
    channel = Helpers.get_by!(Channel, :name, name)
    html =
      "room_info.html"
      |> AdminView.render(channel: channel, current_user: current_user, can_edit: true, editing: %{})
      |> safe_to_string

    {:reply, {:ok, %{html: html, title: "User Info"}}, socket}
  end

  def handle_in("flex:action:" <> action, %{"username" => username} = params, socket) do
    resp = case Helpers.get_by(User, :username, username, preload: [:roles, :account]) do
      nil ->
        {:error, %{error: ~g(User ) <> username <> ~g( does not exist.)}}
      user ->
        flex_action(action, user, username, params, socket)
    end
    {:reply, resp, socket}
  end

  def handle_in(ev = "flex:row-info", params, socket) do
    debug ev, params
    {:noreply, socket}
  end

  defp flex_action("edit-user", user, _username, _params, socket) do
    current_user = Helpers.get_user socket.assigns.user_id
    html =
      "admin_edit_user.html"
      |> AdminView.render(user: user, current_user: current_user)
      |> safe_to_string
    {:ok, %{html: html, title: "Edit User"}}
  end

  defp flex_action(action, user, _username, _params, _socket) when action in ~w(make-admin remove-admin) do
    [role1, role2, success, error] =
      if action == "make-admin" do
        ["user", "admin", ~g(User is now an admin), ~g(Problem  making the an admin)]
      else
        ["admin", "user", ~g(User is no longer an admin), ~g(Problem encountered. User is still an admin)]
      end

    (from r in UserRole, where: r.user_id == ^(user.id) and r.role == ^role1 and r.scope == 0)
    |> Repo.one
    |> Repo.delete

    %UserRole{}
    |> UserRole.changeset(%{user_id: user.id, role: role2, scope: 0})
    |> Repo.insert
    |> case do
      {:ok, _} ->
        html =
          user.id
          |> Helpers.get_user
          |> AdminView.render_user_action_button("admin")
          |> safe_to_string
        {:ok, %{success: success, code_update: %{selector: "button." <> action, action: "replaceWith", html: html}}}
      {:error, _} ->
        {:error, %{error: error}}
    end
  end

  defp flex_action(action, user, _username, _params, _socket) when action in ~w(activate deactivate) do
    [active, success, error] =
      if action == "activate" do
        [true, ~g(User has been activated), ~g(Problem activating User)]
      else
        [false, ~g(User has been deactivated), ~g(Problem encountered. User is still activated)]
      end

    user
    |> User.changeset(%{active: active})
    |> Repo.update
    |> case do
      {:ok, user} ->
        html =
          user
          |> AdminView.render_user_action_button("activate")
          |> safe_to_string
        {:ok, %{success: success, code_update: %{selector: "button." <> action, action: "replaceWith", html: html}}}
      {:error, _} ->
        {:error, %{error: error}}
    end
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

  def render_info(_user) do
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
  defp get_args("users", user) do
    users = Repo.all(User)
    [user: user, users: users]
  end
  defp get_args("rooms", user) do
    # view_a = String.to_atom view
    # mod = Module.concat Config, String.capitalize(view)
    rooms = Repo.all(from c in Channel, preload: [:subscriptions, :messages])
    [user: user, rooms: rooms]
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
    total = UserService.total_users_count()
    online = UserService.online_users_count()

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
