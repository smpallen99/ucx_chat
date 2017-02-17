defmodule UcxChat.FlexBarView do
  use UcxChat.Web, :view

  # "Showing: <b>1<b>, Online: 1, Total: 1 users"
  def get_clients_list_stats(clients) do
    showing = online = total = length(clients)
    Phoenix.HTML.Tag.content_tag :span do
      [
        "Showing: ",
        Phoenix.HTML.Tag.content_tag :b do
          showing
        end,
        ", Online: #{online}, Total: #{total} users"
      ]
    end
    # |> Phoenix.HTML.safe_to_string
  end

  def get_li_class(item, class) do
    with acc <- [to_string(class) | ~w(message background-transparent-dark-hover)],
         acc <- if(item[:own], do: ["own"|acc], else: acc),
         acc <- if(item[:new_day], do: ["new-day"|acc], else: acc) do
      Enum.join(acc, " ")
    end
  end
end
