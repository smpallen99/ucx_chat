defmodule UcxChat.EmojiService do
  use UcxChat.Web, :service
  use UcxChat.ChannelApi

  alias UcxChat.{Emoji, Account, EmojiView, AccountService}

  require Logger

  def handle_in(ev = "click:open_picker", params, socket) do
    debug ev, params
    {:noreply, socket}
  end
  def handle_in(ev = "click:close_picker", params, socket) do
    debug ev, params
    {:noreply, socket}
  end
  def handle_in(ev = "tone_list", params, socket) do
    debug ev, params
    set_emoji_tone socket.assigns.user_id, params["tone"]
    {:reply, {:ok, %{tone_list: Emoji.tone_list(params["tone"])}}, socket}
  end
  def handle_in(ev = "filter-item", params, socket) do
    debug ev, params
    set_emoji_category socket.assigns.user_id, params["name"]
    {:noreply, socket}
  end
  def handle_in(ev = "search", params, socket) do
    debug ev, params
    user = Helpers.get_user socket.assigns.user_id
    pattern = case params["pattern"] do
      ":" <> pattern -> pattern
      pattern -> pattern
    end
    emojis = Emoji.search(pattern, params["category"])
    html =
      "emoji_category.html"
      |> EmojiView.render(emojis: emojis, tone_list: Emoji.tone_list(), tone: EmojiView.tone_append(user.account.emoji_tone))
      |> safe_to_string

    {:reply, {:ok, %{html: html}}, socket}
  end
  def handle_in(ev = "recent", params, socket) do
    debug ev, params
    emoji = String.replace(params["recent"], ":", "")
    case update_emoji_recent(socket.assigns.user_id, emoji) do
      {:ok, account} ->
        html =
          "emoji_category.html"
          |> EmojiView.render(emojis: AccountService.emoji_recents(account), tone_list: Emoji.tone_list(), tone: EmojiView.tone_append(account.emoji_tone))
          |> safe_to_string
        {:reply, {:ok, %{html: html}}, socket}
      {:error, _} ->
        {:reply, {:error, %{error: ~g(Problem updating emoji recent)}}, socket}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_in(ev, params, socket) do
    Logger.warn "Unknown event #{ev}, params: #{inspect params}"
    {:noreply, socket}
  end

  defp update_emoji_recent(user_id, emoji) do
    user_id
    |> get_account
    |> AccountService.update_emoji_recent(emoji)
  end

  defp set_emoji_category(user_id, name) do
    user_id
    |> get_account
    |> Account.changeset(%{emoji_category: name})
    |> Repo.update
  end

  defp set_emoji_tone(user_id, tone) do
    user_id
    |> get_account
    |> Account.changeset(%{emoji_tone: tone})
    |> Repo.update
  end

  def get_account(user_id) do
    user_id
    |> Account.get
    |> Repo.one
  end
end
