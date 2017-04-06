defmodule UcxChat.FlexBarIntegrationTest do
  # use UcxChat.AcceptanceCase
  use UcxChat.ConnCase
  use Hound.Helpers

  # alias UcxChat.{FlexBarService}
  require Logger


  hound_session()

  setup do
    subs = insert(:basic_setup)
    user = insert_user(subs.user.id)
    current_window_handle() |> maximize_window
    login_user(user)
    {:ok, subs: subs, user: user}
  end

  # broken
  # test "finds buttons", %{user: _user} do
  #   for name <- FlexBarService.visible_tab_names() do
  #     assert find_element(:xpath, ~s|//div[contains(@class, 'tab-button') and contains(@title, '#{name}')]|)
  #   end
  # end

end
