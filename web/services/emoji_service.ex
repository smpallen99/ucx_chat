defmodule UcxChat.EmojiService do
  use UcxChat.Web, :service
  use UcxChat.ChannelApi

  require Logger

  def handle_in(ev = "click:open_picker", params, socket) do
    debug ev, params
    {:noreply, socket}
  end
  def handle_in(ev = "click:close_picker", params, socket) do
    debug ev, params
    {:noreply, socket}
  end
  def handle_in(ev, params, socket) do
    Logger.warn "Unknown event #{ev}, params: #{inspect params}"
    {:noreply, socket}
  end

  defp get_emojis do
    %{
      categories: [
        %{ name: :recent, title: "Frequently Used" },
        %{ name: :people, title: "Smileys & People" },
        %{ name: :nature, title: "Animals & Nature" },
        %{ name: :food, title: "Food & Drink" },
        %{ name: :activity, title: "Activity" },
        %{ name: :travel, title: "Travel & Places" },
        %{ name: :objects, title: "Objects" },
        %{ name: :symbols, title: "Symbols" },
        %{ name: :flags, title: "Flags" }
      ],
      emoji_list: %{
        recent: [],
        people: [
        ]
      }

    }
  end

end
