defmodule UcxChat.Message do
  use UcxChat.Web, :model

  schema "messages" do
    field :body, :string
    field :sequential, :boolean, default: false
    belongs_to :client, UcxChat.Client
    belongs_to :channel, UcxChat.Channel

    field :is_groupable, :boolean, virtual: true
    field :system, :string, virtual: true
    field :t, :string, virtual: true
    field :own, :boolean, virtual: true
    field :is_temp, :boolean, virtual: true
    field :chat_opts, :boolean, virtual: true
    field :custom_class, :string, virtual: true
    field :avatar, :string, virtual: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body, :client_id, :channel_id, :sequential])
    |> validate_required([:body, :client_id])
  end

  def format_date(%NaiveDateTime{} = dt) do
    {{yr, mo, day}, _} = NaiveDateTime.to_erl(dt)
    month(mo) <> " " <> to_string(day) <> ", " <> to_string(yr)
  end

  def format_time(%NaiveDateTime{} = dt) do
    {_, {hr, min, _sec}} = NaiveDateTime.to_erl(dt)
    min = to_string(min) |> String.pad_leading(2, "0")
    {hr, meridan} =
      case hr do
        hr when hr < 12 -> {hr, " AM"}
        hr when hr == 12 -> {hr, " PM"}
        hr -> {hr - 12, " PM"}
      end
    to_string(hr) <> ":" <> min <> meridan
  end

  def format_date_time(%NaiveDateTime{} = dt) do
    format_date(dt) <> " " <> format_time(dt)
  end

  def format_timestamp(%NaiveDateTime{} = dt) do
    {{yr, mo, day}, {hr, min, sec}} = NaiveDateTime.to_erl(dt)
    pad2(yr) <> pad2(mo) <> pad2(day) <> pad2(hr) <> pad2(min) <> pad2(sec)
  end

  def pad2(int), do: int |> to_string |> String.pad_leading(2, "0")

  def month(1), do: "January"
  def month(2), do: "February"
  def month(3), do: "March"
  def month(4), do: "April"
  def month(5), do: "May"
  def month(6), do: "June"
  def month(7), do: "July"
  def month(8), do: "August"
  def month(9), do: "September"
  def month(10), do: "October"
  def month(11), do: "November"
  def month(12), do: "December"

end
  # def handle_in("channels:get", message, socket) do
  #   channel_id = message["channel_id"]
  #   client_id = message["client_id"]
  #   channels =
  #     Channel
  #     |> where([c], c.client_id == ^client_id)
  #     |> Repo.all
  #     |> Enum.map(fn chan ->
  #       %{active: false, unread: false, alert: false, user_status: "off-line",
  #         room_icon: "icon-hash", archived: false, name: chan.name}
  #     end)
  #   out_message = %{rooms: channels}
  #   {:reply, {:ok, out_message}}, socket}
  # end
  # def handle_in("message:get", message, socket) do
  #   cid = message["channel_id"]
  #   messages =
  #     Message
  #     |> where([m], m.channel_id == ^cid)
  #     |> join(:left, [m], c in assoc(m, :client))
  #     |> select([m,c], {m.id, m.body, m.updated_at, c.id, c.nickname})
  #     |> Repo.all
  #     |> Enum.map(fn {id, body, updated_at, client_id, nickname} ->
  #       create_message_message(id, body, updated_at, client_id, nickname)
  #     end)
  #   # UcxChat.Endpoint.broadcast("ucxchat:room-" <> message["room"], "message:list", %{messages: messages})
  #   {:reply, {:ok, %{messages: messages}}, socket}
  # end

  # def handle_in("message:new", %{"nickname" => nickname, "channel_id" => cid, "message" => message, "client_id" => client_id, "room" => room} = msg, socket) do
  #   Logger.warn "handle_in message:new, msg: #{inspect msg}"
  #   message = Message.changeset(%Message{}, %{channel_id: cid, client_id: client_id, body: message})
  #   |> Repo.insert!
  #   # msg = %{ts: %{day: 1, mo: 2, yr: 3}, id: message.id, nickname: nickname, date: "February 11, 2017", timestamp: 111111, message: message.body, client_id: client_id}
  #   # UcxChat.Endpoint.broadcast("ucxchat:room-" <> room, "message:single", msg)
  #   send_message_message(room, message, client_id, nickname)
  #   {:noreply, socket}
  # end
  # def handle_in(topic, msg, socket) do
  #   Logger.warn "handle_in topic: #{topic}, msg: #{inspect msg}"
  #   {:noreply, socket}
  # end

  # defp send_message_message(room, %{id: id, body: body, updated_at: updated_at}, client_id, nickname) do
  #   send_message_message(room, id, body, updated_at, client_id, nickname)
  # end
  # defp send_message_message(room, id, body, updated_at, client_id, nickname) do
  #   msg = create_message_message(id, body, updated_at, client_id, nickname)
  #   UcxChat.Endpoint.broadcast("ucxchat:room-" <> room, "message:list", %{messages: [msg]})
  # end
  # defp create_message_message(id, body, updated_at, client_id, nickname) do
  #   {{yr, mo, day}, {hr, min, sec}} = NaiveDateTime.to_erl(updated_at)
  #   ts = %{yr: yr, mo: mo, day: day, hr: hr, min: min, sec: sec}
  #   %{id: id, message: body, nickname: nickname, client_id: client_id, ts: ts}
  # end

