defmodule UcxChat.AdminView do
  use UcxChat.Web, :view

  def has_permission(_user, _permission), do: true
end
