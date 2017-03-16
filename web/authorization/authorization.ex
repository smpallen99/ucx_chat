# defprotocol UcxChat.Authorization do
#   @fallback_to_any true
#   def authorize_action(resource, conn, action)

# end

# defimpl UcxChat.Authorization, for: Any do
#   # def authorize_query(_, _, query, _, _), do: query
#   def authorize_action(_, _, _), do: true
# end

# defimpl UcxChat.Authorization, for: UcxChat.UserSocket do
#   def authorize_action(%{assigns: %{user_id: user_id}} = socket, action, _) when action in ~w(archive unarchive) do
#     UcxChat.Permission.has_permission?("archive-room")
#   end
#   def authorize_action(_, _, _), do: false
# end

# defmodule UcxChat.Authorize do
#   import UcxChat.Gettext

#   def can?(socket, action, params, fun) do
#     if UcxChat.Authorization.authorize_action socket, action, params do
#       fun.()
#     else
#       {:reply, {:error, %{:error, gettext("You are not authorized")}}, socket}
#     end
#   end


# end
