defmodule UcxChat.FlexAdminService do
  use UcxChat.Web, :service
  require Logger

  def default_settings("user") do
    [
      %{title: ~g"Invite Users", icon: "paper-plane", display: "", templ: ""},
      %{title: ~g"Add User", icon: "plus", display: "", templ: ""},
      %{title: ~g"User Info", icon: "user", display: "", templ: "user_card.html"},
    ]
  end
  def default_settings("room") do
    [
      %{title: ~g"Room Info", icon: "info-circled", display: "", templ: ""},
    ]
  end

      # {"IM Mode", "chat", ""},
      # {"Rooms Mode", "hash", " hidden"},
      # {"Info", "info-circled", ""},
    # |> Enum.map(fn {title, icon, display} ->
    #   if tab[title] do
    #     titlea = String.to_atom title
    #     %{title: title, icon: icon, display: display, open: true, templ: defn[titlea][:templ] }
    #   else
    #     display = check_im_mode_display(title, user.account.chat_mode, display)
    #     %{title: title, icon: icon, display: display}
    #   end
    # end)

  def get_render_args("User Info", user_id, channel_id, _, _)  do
    Logger.warn "==== User Info render args"
    user = current_user = Helpers.get_user! user_id
    # channel = Helpers.get_channel(channel_id)
    # direct = (from d in Direct,
    #   where: d.user_id == ^user_id and d.channel_id == ^(channel.id))
    # |> Repo.one

    # user = Helpers.get_user_by_name(direct.users, [:roles, :account])
    # user_info = user_info(channel, direct: true)
    [user: user, current_user: current_user, channel_id: 0]
  end

  # def user_info(opts \\ []) do
  #   show_admin = opts[:admin] || false
  #   direct = opts[:direct] || false
  #   user_mode = opts[:user_mode] || false
  #   view_mode = opts[:view_mode] || false

  #   %{direct: direct, show_admin: show_admin, blocked: channel.blocked, user_mode: user_mode, view_mode: view_mode}
  # end
end
