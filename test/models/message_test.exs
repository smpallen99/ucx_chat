defmodule UcxChat.MessageTest do
  use UcxChat.ModelCase

  alias UcxChat.Message

  @valid_attrs %{body: "some content", client_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Message.changeset(%Message{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "format_date_time" do
    dt = NaiveDateTime.from_erl! {{2017, 1, 1}, {1, 1, 0}}
    assert Message.format_date_time(dt) == "January 1, 2017 1:01 AM"
  end
end
