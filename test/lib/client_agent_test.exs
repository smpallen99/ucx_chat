defmodule UcxChat.ClientAgentTest do
  use ExUnit.Case

  alias UcxChat.ClientAgent

  setup do
    ClientAgent.clear
    :ok
  end

  @title1  "Stared Messages"
  @title2  "Pinned Messages"

  describe "ftab" do

   test "opens one" do
    ClientAgent.open_ftab(1, 1, @title1, nil)
    assert ClientAgent.get_ftab(1,1) == %{title: @title1, args: %{}}
   end

   test "opens view" do
    ClientAgent.open_ftab(1, 1, @title1, {"nickname", "joe"})
    assert ClientAgent.get_ftab(1,1) == %{title: @title1, args: %{"nickname" => "joe"}}
   end

   test "opens multiple" do
    ClientAgent.open_ftab(1, 1, @title2, nil)
    ClientAgent.open_ftab(1, 2, @title1, nil)
    assert ClientAgent.get_ftab(1,1) == %{title: @title2, args: %{}}
    assert ClientAgent.get_ftab(1,2) == %{title: @title1, args: %{}}
   end

   test "opens new" do
    ClientAgent.open_ftab(1, 1, @title1, {"nickname", "joe"})
    ClientAgent.open_ftab(1, 1, @title2, nil)
    assert ClientAgent.get_ftab(1,1) == %{title: @title2, args: %{}}
    ClientAgent.close_ftab(1, 1)
    assert ClientAgent.get() == %{ftab: %{{1,1} => nil}}
   end

   test "closes" do
    ClientAgent.open_ftab(1, 1, @title1, nil)
    ClientAgent.open_ftab(1, 2, @title2, nil)
    ClientAgent.close_ftab(1, 1)
    refute ClientAgent.get_ftab(1,1)
    assert ClientAgent.get_ftab(1,2) == %{title: @title2, args: %{}}
   end
 end
end
