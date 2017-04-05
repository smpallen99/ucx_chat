defmodule UcxChat.ReactionService do
  use UcxChat.Web, :service

  alias UcxChat.{Message, MessageService, Reaction, User}

  require Logger

  def select("select", params, %{assigns: assigns} = _socket) do
    # Logger.warn "ReactionService.select message_id: " <> params["message_id"]
    user = Helpers.get_user assigns.user_id
    emoji = params["reaction"]

    message = Helpers.get Message, params["message_id"], preload: MessageService.preloads()

    case Enum.find message.reactions, &(&1.emoji == emoji) do
      nil ->
        insert_reaction emoji, message.id, user.id
      reaction ->
        update_reaction reaction, user.id
    end
    MessageService.broadcast_updated_message message, reaction: true
    nil
  end

  def insert_reaction(emoji, message_id, user_id) do
    %Reaction{}
    |> Reaction.changeset(%{emoji: emoji, message_id: message_id, user_ids: user_id, count: 1})
    |> Repo.insert
    |> case do
      {:ok, _} ->
        nil
      {:error, _cs} ->
        {:error, %{error: ~g(Problem adding reaction)}}
    end
  end

  def update_reaction(reaction, user_id) do
    user_ids = reaction_user_ids reaction

    case Enum.any?(user_ids, &(&1 == user_id)) do
      true ->
        remove_user_reaction(reaction, user_id, user_ids)
      false ->
        add_user_reaction(reaction, user_id, user_ids)
    end
  end

  defp remove_user_reaction(%{count: count} = reaction, user_id, user_ids) do
    user_ids =
      user_ids
      |> Enum.reject(&(&1 == user_id))
      |> Enum.join(" ")

    if user_ids == "" do
      Repo.delete reaction
    else
      reaction
      |> Reaction.changeset(%{count: count - 1, user_ids: user_ids})
      |> Repo.update
    end
  end

  defp add_user_reaction(%{count: count} = reaction, user_id, user_ids) do
    user_ids =
      (user_ids ++ [user_id])
      |> Enum.join(" ")

    reaction
    |> Reaction.changeset(%{count: count + 1, user_ids: user_ids})
    |> Repo.update
  end

  defp reaction_user_ids(reaction) do
    String.split(reaction.user_ids, " ", trim: true)
  end

  def get_reaction_people_names(reaction, user) do
    username = user.username
    reaction
    |> reaction_user_ids
    |> Enum.map(&(Helpers.get User, &1))
    |> Enum.reject(&(is_nil &1))
    |> Enum.map(fn user ->
      case user.username do
        ^username -> "You"
        username -> username
      end
    end)
    |> case do
      [one] -> one
      [first | rest] ->
        Enum.join(rest, ", ") <> " and " <> first
    end
  end

end
