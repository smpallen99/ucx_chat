defmodule UcxChat.ChannelControllerTest do
  use UcxChat.ConnCase

  alias UcxChat.Channel
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, channel_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing channels"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, channel_path(conn, :new)
    assert html_response(conn, 200) =~ "New channel"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, channel_path(conn, :create), channel: @valid_attrs
    assert redirected_to(conn) == channel_path(conn, :index)
    assert Repo.get_by(Channel, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, channel_path(conn, :create), channel: @invalid_attrs
    assert html_response(conn, 200) =~ "New channel"
  end

  test "shows chosen resource", %{conn: conn} do
    channel = Repo.insert! %Channel{}
    conn = get conn, channel_path(conn, :show, channel)
    assert html_response(conn, 200) =~ "Show channel"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, channel_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    channel = Repo.insert! %Channel{}
    conn = get conn, channel_path(conn, :edit, channel)
    assert html_response(conn, 200) =~ "Edit channel"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    channel = Repo.insert! %Channel{}
    conn = put conn, channel_path(conn, :update, channel), channel: @valid_attrs
    assert redirected_to(conn) == channel_path(conn, :show, channel)
    assert Repo.get_by(Channel, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    channel = Repo.insert! %Channel{}
    conn = put conn, channel_path(conn, :update, channel), channel: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit channel"
  end

  test "deletes chosen resource", %{conn: conn} do
    channel = Repo.insert! %Channel{}
    conn = delete conn, channel_path(conn, :delete, channel)
    assert redirected_to(conn) == channel_path(conn, :index)
    refute Repo.get(Channel, channel.id)
  end
end
