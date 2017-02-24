defmodule UcxChat.FlexTest do
  use ExUnit.Case, async: true
  doctest UcxChat.Flex

  alias UcxChat.Flex

  setup do
    {:ok, fl: Flex.new}
  end

  test "open?", %{fl: fl} do
    refute Flex.open?(fl, 0)
  end

  test "open/4", %{fl: fl} do
    assert Flex.open(fl, 1, "Info", %{}) |> Flex.open?(1)
    assert_receive {:flex, :open, 1, "Info", nil, %{}}
  end

  test "toggle/3", %{fl: fl} do
    assert Flex.toggle(fl, 1, "Info") |> Flex.open?(1)
    assert_receive {:flex, :open, 1, "Info", nil, %{}}
  end

  test "close/3", %{fl: fl} do
    ch = 2
    tab = "a b"
    fl =  Flex.open(fl, ch, tab, %{})
    assert_receive {:flex, :open, ^ch, ^tab, nil, %{}}
    assert Flex.open?(fl, ch)

    refute Flex.close(fl, ch, tab) |> Flex.open?(ch)
    assert_receive {:flex, :close, ^ch, ^tab, nil, %{}}
  end

  test "toggle open close", %{fl: fl} do
    ch = 3
    tab = "a"
    refute fl |> Flex.toggle(ch, tab) |> Flex.toggle(ch, tab) |> Flex.open?(ch)
    assert_receive {:flex, :open, ^ch, ^tab, nil, %{}}
    assert_receive {:flex, :close, ^ch, ^tab, nil, %{}}
  end

  test "toggle open to different page", %{fl: fl} do
    ch = 3
    tab = "a"
    tab2 = "b"
    fl = fl |> Flex.toggle(ch, tab) |> Flex.toggle(ch, tab2)
    assert fl |> Flex.open?(ch)
    assert fl |> Flex.open_tab_name(ch) == tab2

  end

  test "open/5", %{fl: fl} do
    ch = 100
    tab = "Members List"
    args = %{name: "a"}
    args_expected = %{tab => args}

    fl = Flex.open(fl, ch, tab, args, %{})
    assert Flex.open?(fl, ch)
    assert_receive {:flex, :open, ^ch, ^tab, ^args_expected, %{}}
  end

  test "toggle with args open", %{fl: fl} do
    ch = 1
    tab = "a"
    args = %{user: "abc"}
    args_expected = %{tab => args}
    fl = Flex.open(fl, ch, tab, args, %{}) |> Flex.toggle(ch, tab)
    refute Flex.open?(fl, ch)
    assert_receive {:flex, :open, ^ch, ^tab, ^args_expected, %{}}
    assert_receive {:flex, :close, ^ch, ^tab, nil, %{}}

    fl = Flex.toggle(fl, ch, tab)
    assert Flex.open?(fl, ch)
    assert_receive {:flex, :open, ^ch, ^tab, ^args_expected, %{}}
  end

  test "view_all", %{fl: fl} do
    ch = 2
    tab = "a b"
    args = %{user: "abc"}
    args_expected = %{tab => args}
    fl = Flex.open(fl, ch, tab, args, %{})
    assert Flex.open?(fl, ch)
    assert Flex.panel_active?(fl, ch, tab)
    assert_receive {:flex, :open, ^ch, ^tab, ^args_expected, %{}}

    fl = Flex.view_all(fl, ch, tab)
    assert Flex.open?(fl, ch)
    refute Flex.panel_active?(fl, ch, tab)
    refute_receive {:flex, _, _, _, _, _}

  end
end

