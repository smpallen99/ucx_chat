defmodule UcxChat.RoomSettingChannelController do
  use UcxChat.Web, :channel_controller

  import Phoenix.Channel

  alias UcxChat.{Subscription, FlexBarView, Channel, FlexBarService, ChannelService}
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger

  def edit(%{assigns: assigns} = socket, params) do
    channel = Helpers.get(Channel, assigns[:channel_id])
    field_name = String.to_atom(params["field_name"])
    value = Map.get channel, field_name
    html = FlexBarView.render("channel_form_text_input.html", field: %{name: field_name, value: value})
    |> Phoenix.HTML.safe_to_string
    {:reply, {:ok, %{html: html}}, socket}
  end

  def cancel(%{assigns: assigns} = socket, params) do
    channel = Helpers.get(Channel, assigns[:channel_id])
    field = FlexBarService.get_setting_form_field(params["field_name"], channel, assigns[:user_id])
    html = FlexBarView.flex_form_input(field[:type], field)
    |> Enum.map(&Phoenix.HTML.safe_to_string/1)
    |> Enum.join
    {:reply, {:ok, %{html: html}}, socket}
  end

  def update(%{assigns: assigns} = socket, params) do
    # Logger.warn "RoomSettingChannelController assigns: #{inspect assigns}, params: #{inspect params}"
    user = Helpers.get_user! socket
    Channel
    |> Helpers.get(assigns[:channel_id])
    |> Channel.changeset_settings(user, [{params["field_name"], params["value"]}])
    |> Repo.update
    |> case do
      {:ok, channel} ->
        update_archive_hidden(channel, params["field_name"], params["value"])
        field = FlexBarService.get_setting_form_field(params["field_name"], channel, assigns[:user_id])
        html = FlexBarView.flex_form_input(field[:type], field)
        |> case do
          list when is_list(list) ->
            list
            |> Enum.map(&Phoenix.HTML.safe_to_string/1)
            |> Enum.join
          tuple ->
            Phoenix.HTML.safe_to_string(tuple)
        end

        channel = Helpers.get!(Channel, assigns[:channel_id])
        icon = ChannelService.get_icon channel.type

        if params["field_name"] == "name" do
          broadcast! socket, "room:update:name",
            %{
              channel_id: assigns[:channel_id],
              old_name: assigns[:room],
              new_name: params["value"],
              icon: icon
            }
        end

        broadcast! socket, "room:update", %{field_name: params["field_name"], value: params["value"]}
        broadcast! socket, "room:update:list", %{}

        if params["field_name"] in ~w(private read_only archived) do
          # Logger.warn "------------------ assigns: #{inspect socket.assigns}"
          broadcast! socket, "room:state_change", %{change: params["field_name"], channel_id: socket.assigns.channel_id}
        end

        {:reply, {:ok, %{html: html}}, socket}

      {:error, cs} ->
        Logger.warn "error: #{inspect cs.errors}"
        {field, {error, _}} = cs.errors |> hd
        {:reply, {:error, %{error: "#{field} #{error}"}}, socket}
    end

  end

  def update_archive_hidden(%{id: id} = channel, "archived", value) do
    value = if value == true, do: true, else: false
    Subscription
    |> where([s], s.channel_id == ^id)
    |> Repo.update_all(set: [hidden: value])
    channel
  end
  def update_archive_hidden(channel, _type, _value), do: channel

end
