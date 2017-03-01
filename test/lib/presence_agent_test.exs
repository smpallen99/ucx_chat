defmodule UcxChat.PresenceAgentTest do
  use UcxChat.ModelCase
  alias UcxChat.PresenceAgent, as: Agent
  import UcxChat.TestHelpers

  setup do
    Agent.clear
    {:ok, user: insert_client_user()}
  end

  test "load", %{user: user} do
    assert Agent.get(user.id) == "offline"
    Agent.load user.id
    assert Agent.get(user.id) == "online"
  end

  test "load overide" do
    user = insert_client_user(%{chat_status: "busy"})
    Agent.load user.id
    assert Agent.get(user.id) == "busy"
  end

  test "unload", %{user: user} do
    Agent.load user.id
    assert Agent.get(user.id) == "online"
    Agent.unload user.id
    assert Agent.get(user.id) == "offline"
    Agent.load user.id
    assert Agent.get(user.id) == "online"
  end

  test "put", %{user: user} do
    Agent.load user.id
    assert Agent.get(user.id) == "online"
    Agent.put user.id, "away"
    assert Agent.get(user.id) == "away"
    Agent.unload user.id
    assert Agent.get(user.id) == "offline"
    Agent.load user.id
    assert Agent.get(user.id) == "away"
  end

  test "update_presence", %{user: user} do
    Agent.load user.id
    assert Agent.get(user.id) == "online"
    Agent.update_presence user.id, "away"
    assert Agent.get(user.id) == "away"
    Agent.update_presence user.id, "online"
    assert Agent.get(user.id) == "online"
    Agent.update_presence user.id, "busy"
    assert Agent.get(user.id) == "busy"
    Agent.update_presence user.id, "online"
    assert Agent.get(user.id) == "online"
    Agent.put user.id, "away"
    assert Agent.get(user.id) == "away"
    Agent.update_presence user.id, "online"
    assert Agent.get(user.id) == "away"
    Agent.put user.id, "online"
    assert Agent.get(user.id) == "online"
    Agent.update_presence user.id, "busy"
    assert Agent.get(user.id) == "busy"
  end

end
