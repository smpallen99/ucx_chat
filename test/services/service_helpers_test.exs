defmodule UcxChat.ServiceHelpersTest do
  use ExUnit.Case, async: true
  doctest UcxChat.ServiceHelpers
  alias UcxChat.ServiceHelpers, as: Helpers


  test "normalize_form_params" do
    params = [
      %{"name" => "one[two][aa]", "value" => "true"},
      %{"name" => "one[two][ab]", "value" => "false"},
      %{"name" => "one[more]", "value" => "42"},
    ]
    expected = %{"one" => %{"more" => "42", "two" => %{"aa" => "true", "ab" => "false"}}}
    assert Helpers.normalize_form_params(params) == expected
  end
end
