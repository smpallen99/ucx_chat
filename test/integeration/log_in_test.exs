defmodule UcxChat.LogInTest do
  # use UcxChat.AcceptanceCase
  use UcxChat.ConnCase
  import UcxChat.TestHelpers

  require Logger

  use Hound.Helpers

  hound_session()

  setup do
    subs = insert_subscription()
    current_window_handle() |> maximize_window
    {:ok, subs: subs, user: subs.client.user}
  end

  # broken
  # test "login in user", %{user: user} do
  #   login_user(user)

  #   assert find_element(:class, "rooms-list")
  # end
end
