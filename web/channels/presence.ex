defmodule UcxChat.Presence do
  use Phoenix.Presence, otp_app: :ucx_chat,
                        pubsub_server: UcxChat.PubSub

end
