defmodule UcxChat.ChannelService do
  @moduledoc """
  Helper functions used by the controller, channel, and model for Channels
  """
  alias UcxChat.{Repo, Channel, ChannelClient}
  import Ecto.Query

  @public_channel  0
  @private_channel 1
  @direct_message  2
  @stared_room     3

  def room_type(:public), do: @public_channel
  def room_type(:private), do: @private_channel
  def room_type(:dm), do: @direct_message
  def room_type(:stared), do: @stared_room

  @doc """
  Get the side_nav data used in the side_nav templates
  """
  def get_side_nav(%{id: id}) do
    rooms =
      ChannelClient
      |> where([cc], cc.client_id == ^id)
      |> preload([:channel])
      |> Repo.all
      |> Enum.map(fn cc ->
        chan = cc.channel
        %{active: false, unread: false, alert: false, user_status: "off-line", can_leave: true,
          route: get_route(chan.type, chan.name), unread: false, can_leave: true,
          room_icon: get_icon(chan.type), archived: false, name: chan.name, type: chan.type}
      end)
    types = Enum.group_by(rooms, &Map.get(&1, :type))
    room_types = Enum.reduce(types, [], fn {type, list}, acc ->
      map = %{
        can_show_room: true,
        template_name: get_templ(type),
        rooms: list,
      }
      [map|acc]
    end)

    %{room_types: room_types, rooms: []}
  end
    # %li(class="#{chat_room_item_li_class(@item)}")
    #   %a.open-room(href="#{@item[:route]}" title="#{@item[:name]}")
    #     - if @item[:unread] do
    #       %span.unread= @item[:unread]
    #     %i(class="#{@item[:room_icon]} #{@item[:user_status]}" aria-label="")
    #     %span(class="name #{@item[:archived]}")= @item[:name]
    #     - if !! @item[:unread] do
    #       %span.opt
    #         %i.icon-eye-off.hide-room(title="Hide_room" aria-label="Hide_room")
    #         - if @item[:can_leave] do
    #           %i.icon-logout.leave-room(title="Leave_room" aria-label="Leave_room")
    # - for room_type <- @side_nav[:room_types] do
    #   - if room_type[:can_show_room] do
    #     = render room_type[:template_name], conn: @conn  # need to figure out what other args to send here
    # - if @side_nav[:can_view_history] do

  def get_templ(@stared_room), do: "stared_rooms.html"
  def get_templ(@direct_message), do: "direct_messages.html"
  def get_templ(_), do: "channels.html"

  def get_icon(@public_channel), do: "icon-hash"
  def get_icon(@private_channel), do: "icon-hash"
  def get_icon(_), do: "icon-star"


  def get_route(@stared_room, name), do: "/direct/" <> name
  def get_route(@direct_message, name), do: "/direct/" <> name
  def get_route(_, name), do: "/channel/" <> name
end
