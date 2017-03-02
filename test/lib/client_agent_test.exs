defmodule UcxChat.UserAgentTest do
  use ExUnit.Case

  alias UcxChat.UserAgent

  setup do
    UserAgent.clear
    :ok
  end

  @title1  "Stared Messages"
  @title2  "Pinned Messages"

  describe "ftab" do

   test "opens one" do
    UserAgent.open_ftab(1, 1, @title1, nil)
    assert UserAgent.get_ftab(1,1) == %{title: @title1, args: %{}}
   end

   test "opens view" do
    UserAgent.open_ftab(1, 1, @title1, {"username", "joe"})
    assert UserAgent.get_ftab(1,1) == %{title: @title1, args: %{"username" => "joe"}}
   end

   test "opens multiple" do
    UserAgent.open_ftab(1, 1, @title2, nil)
    UserAgent.open_ftab(1, 2, @title1, nil)
    assert UserAgent.get_ftab(1,1) == %{title: @title2, args: %{}}
    assert UserAgent.get_ftab(1,2) == %{title: @title1, args: %{}}
   end

   test "opens new" do
    UserAgent.open_ftab(1, 1, @title1, {"username", "joe"})
    UserAgent.open_ftab(1, 1, @title2, nil)
    assert UserAgent.get_ftab(1,1) == %{title: @title2, args: %{}}
    UserAgent.close_ftab(1, 1)
    assert UserAgent.get() == %{ftab: %{{1,1} => nil}}
   end

   test "closes" do
    UserAgent.open_ftab(1, 1, @title1, nil)
    UserAgent.open_ftab(1, 2, @title2, nil)
    UserAgent.close_ftab(1, 1)
    refute UserAgent.get_ftab(1,1)
    assert UserAgent.get_ftab(1,2) == %{title: @title2, args: %{}}
   end
 end
end
