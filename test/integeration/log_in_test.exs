defmodule UcxChat.LogInTest do
  # use UcxChat.AcceptanceCase
  use UcxChat.ConnCase

  require Logger

  use Hound.Helpers

  hound_session()

  setup do
    subs = insert(:basic_setup)
    user = insert_user(subs.client.id)
    current_window_handle() |> maximize_window
    {:ok, subs: subs, user: user}
  end

  test "login in user", %{user: user} do
    login_user(user)

    assert find_element(:class, "rooms-list")
  end
end
