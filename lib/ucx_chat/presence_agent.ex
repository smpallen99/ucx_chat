defmodule UcxChat.PresenceAgent do
  @moduledoc """
  Handles presence status for use with views.

  This module works in conjunction with Phoenix.Presence to manage presence
  state for the application.

  While the channel presence is responsible for notifying of state changes,
  this module provides this state to the controllers and views. Furthermore,
  state overrides are handled her.

  """
  import Ecto.Query

  alias UcxChat.{Repo, User}

  require Logger

  @name __MODULE__
  # @audit_secs 120

  def start_link do
    # spawn fn ->
    #   :timer.sleep(2000)
    #   @name.startup()
    # end
    Agent.start_link(fn -> %{} end, name: @name)
  end

  @doc """
  Read the data base and record with users have an overridden presence status.
  """
  def startup do
    # query =
    #   from u in User,
    #     join: c in User, on: c.id == u.user_id,
    #     select: {u.id, c.chat_status}

    # users =
    #   query
    #   |> Repo.all
    #   |> Enum.map(fn
    #     {id, nil} = default -> {to_string(id), nil}
    #     {id, status} -> {to_string(id), {:override, status}}
    #   end)
    #   |> Enum.into(%{})

    # Agent.update(@name, fn _ -> users end)
  end

  @doc """
  Load a user's status.

  Called in a number of scenarios
    * User logs in
    * User reloads browser

  Reads the User's status form the database. If set, uses that as
  an override. Otherwise, sets the status to "online"
  """
  def load(user_id) when is_binary(user_id) do
    query =
      from u in User,
        where: u.id == ^user_id,
        select: u.chat_status

    status =
      query
      |> Repo.one
      |> case do
        nil    -> "online"
        status -> {:override, status}
      end

    Agent.update(@name, &Map.put(&1, to_string(user_id), status))
  end

  @doc """
  Logs a user out by clearing their entry in the status list.
  """
  # def unload(user_id) when is_integer(user_id) do
  #   user_id |> to_string |> unload
  # end
  def unload(user) do
    Agent.update(@name, &Map.delete(&1, user))
  end

  # def update_presence(user_id, status) when is_integer(user_id),
  #   do: user_id |> to_string |> update_presence(status)

  def update_presence(user, status) do
    Agent.update @name, fn state ->
      update_in state, [user], fn
        {:override, _} = override -> override   # don't change the override
        _ -> status                            # new status
      end
    end
  end

  # def get_and_update_presence(user_id, status) when is_integer(user_id),
  #   do: user_id |> to_string |> get_and_update_presence(status)

  def get_and_update_presence(user, status) do
    Agent.get_and_update @name, fn state ->
      get_and_update_in state, [user], fn
        {:override, val} = override -> {val, override}   # don't change the override
        _ -> {status, status}                            # new status
      end
    end
  end
  # Agent.get_and_update name, &(get_and_update_in(&1, ["18"], fn state -> {"busy", "busy"} end))

  @doc """
  Change user status.

  Called when the user selects a status from the side nav. Status is
  stored in the database unless its "online", where its removed from
  the database.
  """
  # def put(user_id, status) when is_integer(user_id) do
  #   user = to_string user_id
  #   put(user_id, user, status)
  # end
  def put(user_id, status) when is_binary(user_id) do
    put(user_id, user_id, status)
  end

  def put(user_id, user, "online") do
    set_chat_status(user_id, nil)
    Agent.update(@name, &Map.put(&1, user, "online"))
  end
  def put(user_id, user, "invisible") do
    put(user_id, user, "offline")
  end
  def put(user_id, user, status) do
    set_chat_status(user_id, status)
    Agent.update(@name, &Map.put(&1, user, {:override, status}))
  end

  # def get(user_id) when is_integer(user_id),
  #   do: user_id |> to_string |> get

  def get(user) do
    case Agent.get @name, &Map.get(&1, user) do
      {:override, status} -> status
      nil -> "offline"
      status -> status
    end
  end

  # def active?(user_id) when is_integer(user_id),
  #   do: user_id |> to_string |> active?

  def active?(user) do
    not is_nil(Agent.get(@name, &Map.get(&1, user)))
    # @name |> Agent.get(&Map.get(&1, user)) |> is_nil |> not
  end

  def all do
    Agent.get @name, &(&1)
  end

  def clear do
    Agent.update @name, fn _ -> %{} end
  end

  defp user(user_id) do
    Repo.one!(from u in User, where: u.id == ^user_id)
  end

  defp set_chat_status(user_id, status) do
    user_id
    |> user
    |> User.changeset(%{chat_status: status})
    |> Repo.update
  end

end
