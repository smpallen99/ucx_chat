defmodule UcxChat.RoomSettingChannelController do
  use UcxChat.Web, :channel_controller

  import Phoenix.Channel
  # import UcxChat.NotifierService

  alias UcxChat.{Subscription, FlexBarView, Channel, FlexBarService, ChannelService}
  alias UcxChat.ServiceHelpers, as: Helpers

  require UcxChat.ChatConstants, as: CC
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
    channel = Helpers.get(Channel, assigns[:channel_id])

    socket
    |> update_field(channel, user, params)
    |> case do
      {:ok, _channel} ->
        # Logger.warn "... params: #{inspect params}"
        # notify_action(socket, get_action(params), channel.name, user, channel.id)
        update_archive_hidden(channel, params["field_name"], params["value"])
        field = FlexBarService.get_setting_form_field(params["field_name"], channel, assigns[:user_id])
        html =
          field[:type]
          |> FlexBarView.flex_form_input(field)
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

        unless params["field_name"] == "archived" do
          broadcast! socket, "room:update", %{field_name: params["field_name"], value: params["value"]}
          socket.endpoint.broadcast! CC.chan_room <> channel.name, "room:update:list", %{}
        end

        if params["field_name"] in ~w(private read_only) do
          socket.endpoint.broadcast! CC.chan_room <> channel.name, "room:state_change", %{change: params["field_name"], channel_id: socket.assigns.channel_id}
        end

        {:reply, {:ok, %{html: html}}, socket}

      {:error, cs} ->
        Logger.warn "error: #{inspect cs.errors}"
        {field, {error, _}} = cs.errors |> hd
        {:reply, {:error, %{error: "#{field} #{error}"}}, socket}
    end

  end

  def update_field(%{assigns: assigns} = socket, channel, _user, %{"field_name" => "archived", "value" => true}) do
    ChannelService.channel_command(socket, :archive, channel, assigns.user_id, channel.id)
  end
  def update_field(%{assigns: assigns} = socket, channel, _user, %{"field_name" => "archived"}) do
    ChannelService.channel_command(socket, :unarchive, channel, assigns.user_id, channel.id)
  end
  def update_field(%{assigns: _assigns} = _socket, channel, user, %{"field_name" => field_name, "value" => value}) do
    channel
    |> Channel.changeset_settings(user, [{field_name, value}])
    |> Repo.update
  end

  def update_archive_hidden(%{id: id} = channel, "archived", value) do
    value = if value == true, do: true, else: false
    Subscription
    |> where([s], s.channel_id == ^id)
    |> Repo.update_all(set: [hidden: value])
    channel
  end
  def update_archive_hidden(channel, _type, _value), do: channel

  # defp get_action(%{"field_name" => "archived", "value" => true}), do: :archive
  # defp get_action(%{"field_name" => "archived"}), do: :unarchive
  # defp get_action(_), do: nil

end
