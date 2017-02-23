defmodule UcxChat.RoomSettingChannelController do
  use UcxChat.Web, :channel_controller

  import Phoenix.Channel

  alias UcxChat.{FlexBarView, Channel, FlexBarService}
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
    field = FlexBarService.get_setting_form_field(params["field_name"], channel, assigns[:client_id])
    html = FlexBarView.flex_form_input(field[:type], field)
    |> Enum.map(&Phoenix.HTML.safe_to_string/1)
    |> Enum.join
    {:reply, {:ok, %{html: html}}, socket}
  end

  def update(%{assigns: assigns} = socket, params) do
    Logger.warn "RoomSettingChannelController assigns: #{inspect assigns}, params: #{inspect params}"
    Channel
    |> Helpers.get(assigns[:channel_id])
    |> Channel.changeset_settings([{params["field_name"], params["value"]}])
    |> Repo.update
    |> case do
      {:ok, channel} ->
        field = FlexBarService.get_setting_form_field(params["field_name"], channel, assigns[:client_id])
        html = FlexBarView.flex_form_input(field[:type], field)
        |> case do
          list when is_list(list) ->
            list
            |> Enum.map(&Phoenix.HTML.safe_to_string/1)
            |> Enum.join
          tuple ->
            Phoenix.HTML.safe_to_string(tuple)
        end


        if params["field_name"] == "name" do
          broadcast! socket, "room:update:name",
            %{
              channel_id: assigns[:channel_id],
              old_name: assigns[:room],
              new_name: params["value"],
              icon: "hash"
            }
        end

        broadcast! socket, "room:update", %{field_name: params["field_name"], value: params["value"]}

        {:reply, {:ok, %{html: html}}, socket}

      {:error, cs} ->
        Logger.warn "error: #{inspect cs.errors}"
        {field, {error, _}} = cs.errors |> hd
        {:reply, {:error, %{error: "#{field} #{error}"}}, socket}
    end
  end

  # def handle_in("form:click", msg) do
  #   channel = Helpers.get(Channel, msg["channel_id"])
  #   field_name = String.to_atom(msg["field_name"])
  #   value = Map.get channel, field_name
  #   html = FlexBarView.render("channel_form_text_input.html", field: %{name: field_name, value: value})
  #   |> Phoenix.HTML.safe_to_string
  #   {:ok, %{html: html}}
  # end

  # def handle_in("form:cancel", msg) do
  #   channel = Helpers.get(Channel, msg["channel_id"])
  #   field = get_setting_form_field(msg["field_name"], channel, msg["client_id"])
  #   html = FlexBarView.flex_form_input(field[:type], field)
  #   |> Enum.map(&Phoenix.HTML.safe_to_string/1)
  #   |> Enum.join
  #   {:ok, %{html: html}}
  # end

  # def handle_in("form:save", msg) do
  #   Channel
  #   |> Helpers.get(msg["channel_id"])
  #   |> Channel.changeset_settings([{msg["field_name"], msg["value"]}])
  #   |> Repo.update
  #   |> case do
  #     {:ok, channel} ->
  #       field = get_setting_form_field(msg["field_name"], channel, msg["client_id"])
  #       html = FlexBarView.flex_form_input(field[:type], field)
  #       |> case do
  #         list when is_list(list) ->
  #           list
  #           |> Enum.map(&Phoenix.HTML.safe_to_string/1)
  #           |> Enum.join
  #         tuple ->
  #           Phoenix.HTML.safe_to_string(tuple)
  #       end
  #       {:ok, %{html: html}}
  #     {:error, cs} ->
  #       Logger.warn "error: #{inspect cs.errors}"
  #       {field, {error, _}} = cs.errors |> hd
  #       {:error, %{error: "#{field} #{error}"}}
  #   end
  # end

end
