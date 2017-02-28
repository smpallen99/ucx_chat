defmodule UcxChat.ServiceHelpers do
  alias UcxChat.{Repo, Channel, Client, Subscription, MessageService, User}

  import Ecto.Query

  def get_user!(%Phoenix.Socket{assigns: assigns}) do
    get_user!(assigns[:user_id])
  end

  def get_user!(id) do
    Repo.one!(from u in User, where: u.id == ^id, preload: [:client, :account, :roles])
  end

  def get!(model, id, opts \\ []) do
    preload = opts[:preload] || []
    model
    |> where([c], c.id == ^id)
    |> preload(^preload)
    |> Repo.one!
  end

  def get(model, id, opts \\ []) do
    preload = opts[:preload] || []
    model
    |> where([c], c.id == ^id)
    |> preload(^preload)
    |> Repo.one
  end

  def get_by!(model, field, value, opts \\ []) do
    preload = opts[:preload] || []
    model
    |> where([c], field(c, ^field) == ^value)
    |> preload(^preload)
    |> Repo.one!
  end

  def get_by(model, field, value, opts \\ []) do
    preload = opts[:preload] || []
    model
    |> where([c], field(c, ^field) == ^value)
    |> preload(^preload)
    |> Repo.one
  end

  def get_channel(channel_id, preload \\ []) do
    Channel
    |> where([c], c.id == ^channel_id)
    |> preload(^preload)
    |> Repo.one!
  end

  def get_client(client_id, opts \\ []) do
    preload = opts[:preload] || []
    Client
    |> where([c], c.id == ^client_id)
    |> preload(^preload)
    |> Repo.one!
  end

  def get_channel_client(channel_id, client_id, opts \\ []) do
    preload = opts[:preload] || []

    Subscription
    |> where([c], c.client_id == ^client_id and c.channel_id == ^channel_id)
    |> preload(^preload)
    |> Repo.one!
  end

  def get_client_by_name(nickname, preload \\ [])
  def get_client_by_name(nil, _), do: nil
  def get_client_by_name(nickname, preload) do
    Client
    |> where([c], c.nickname == ^nickname)
    |> preload(^preload)
    |> Repo.one!
  end

  def count(query) do
    query |> select([m], count(m.id)) |> Repo.one
  end

  def last_page(query, page_size \\ 150) do
    count = count(query)
    offset = case count - page_size do
      offset when offset >= 0 -> offset
      _ -> 0
    end
    query |> offset(^offset) |> limit(^page_size)
  end

  @dt_re ~r/(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})\.(\d+)/

  def get_timestamp() do
    @dt_re
    |> Regex.run(DateTime.utc_now() |> to_string)
    |> tl
    |> to_string
    # |> String.to_integer
  end

  def format_date(%NaiveDateTime{} = dt) do
    {{yr, mo, day}, _} = NaiveDateTime.to_erl(dt)
    month(mo) <> " " <> to_string(day) <> ", " <> to_string(yr)
  end
  def format_date(%DateTime{} = dt), do: dt |> DateTime.to_naive |> format_date

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
  def format_time(%DateTime{} = dt), do: dt |> DateTime.to_naive |> format_time

  def format_date_time(%NaiveDateTime{} = dt) do
    format_date(dt) <> " " <> format_time(dt)
  end
  def format_date_time(%DateTime{} = dt), do: dt |> DateTime.to_naive |> format_date_time

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

  def response_message(channel_id, message) do
    body = UcxChat.MessageView.render("message_response_body.html", message: message)
    |> Phoenix.HTML.safe_to_string

    bot_id =
      Client
      # |> where([m], m.type == "b")
      |> select([m], m.id)
      |> limit(1)
      |> Repo.one
    message = MessageService.create_message(body, bot_id, channel_id,
      %{
        type: "p",
        sequential: false,
      })

    html = MessageService.render_message(message)

    %{html: html}
  end

  def render(view, templ, opts \\ []) do
    templ
    |> view.render(opts)
    |> Phoenix.HTML.safe_to_string
  end

  @doc """
  Convert form submission params form channel into params for changesets.

  ## Examples

        iex> params =  [%{"name" => "_utf8", "value" => "✓"},
        ...> %{"name" => "account[language]", "value" => "en"},
        ...> %{"name" => "account[desktop]", "value" => ""},
        ...> %{"name" => "account[alert]", "value" => "1"}]
        iex> UcxChat.ServiceHelpers.normalize_form_params(params)
        %{"_utf8" => "✓", "account" => %{"language" => "en", "alert" => "1"}}
  """
  def normalize_form_params(params) do
    Enum.reduce params, %{}, fn
      %{"name" => _field, "value" => ""}, acc ->
        acc
      %{"name" => field, "value" => value}, acc ->
        parse_name(field)
        |> Enum.reduce(value, fn key, acc -> Map.put(%{}, key, acc) end)
        |> UcxChat.Utils.deep_merge(acc)
    end
  end

  defp parse_name(string), do: parse_name(string, "", [])

  defp parse_name("", "", acc), do: acc
  defp parse_name("", buff, acc), do: [buff|acc]
  defp parse_name("[" <> tail, "", acc), do: parse_name(tail, "", acc)
  defp parse_name("[" <> tail, buff, acc), do: parse_name(tail, "", [buff|acc])
  defp parse_name("]" <> tail, buff, acc), do: parse_name(tail, "", [buff|acc])
  defp parse_name(<<ch::8>> <> tail, buff, acc), do: parse_name(tail, buff <> <<ch::8>>, acc)

  # def render_message(channel_id, message, opts \\ []) do
  #   body = UcxChat.MessageView.render("message_response_body.html", message: message)
  #   |> Phoenix.HTML.safe_to_string

  #   bot_id =
  #     Client
  #     # |> where([m], m.type == "b")
  #     |> select([m], m.id)
  #     |> limit(1)
  #     |> Repo.one
  #   type = if opts[:private] do, do: "p", else: nil
  #   message = MessageService.create_message(body, bot_id, channel_id,
  #     %{
  #       type: type,
  #       sequential: false,
  #     })

  #   {message, MessageService.render_message(message)}
  # end

end
