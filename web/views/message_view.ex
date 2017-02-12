defmodule UcxChat.MessageView do
  use UcxChat.Web, :view

  def file_upload_allowed_media_types do
    ""
  end

  def get_not_subscribed_templ(_mb) do
    %{}
  end

  def get_message_wrapper_opts(msg) do
    cls =
    ~w(get_sequential get_system get_t get_own get_is_temp get_chat_opts get_custom_class)a
    |> Enum.reduce("message background-transparent-dark-hover", fn fun, acc ->
      acc <> apply(__MODULE, fun, [msg])
    end)
    [
      id: msg.id,
      class: cls,
      "data-username": msg.client.nickname,
      "data-groupable": msg.is_groupable,
      "data-date": format_date(msg.updated_at),
      "data-timestamp": format_timestamp(msg.updated_at)
    ]
  end
  def format_date(dt) do

  end
  def format_timestamp(dt) do

  end
  def format_time(msg) do
  end
  def format_date(msg) do

  end
  def format_date_time(msg) do

  end
  def get_avatar(msg) do
    ""
  end
  def avatar_from_username(msg), do: false
  def emoji(msg) do
    false
  end
  def get_username(msg), do: @msg.client.nickname

  def role_tags(_user), do: []
  def is_bot(_msg), do: false
  def get_date_time(msg), do: format_date_time(msg)
  def get_time(msg), do: format_time(msg)
  def edited(_msg), do: false
  def private(_msg), do: false
  def hide_cog(_msg), do: ""
  def attachments(_msg), do: []
  def hide_action_links(_msg), do: ""
  def action_links(_msg), do: []
  def hide_reactions(_msg), do: ""
  def reactions(_msg), do: []
  def mark_user_reaction(_reaction), do: ""
  def render_emoji(_emoji), do: ""

  def get_sequential(%{sequential: true}), do: " sequential"
  def get_sequential(_), do: ""
  def get_system(%{system: system}), do: " #{system}"
  def get_system(_), do: ""
  def get_t(%{t: t}), do: " #{t}"
  def get_t(_), do: ""
  def get_own(%{own: own}), do: " #{own}"
  def get_own(_), do: ""
  def get_is_temp(%{is_temp: is_temp}), do: " #{is_temp}"
  def get_is_temp(_), do: ""
  def get_chat_opts(%{chat_opts: chat_opts}), do: " #{chat_opts}"
  def get_chat_opts(_), do: ""
  def get_custom_class(%{custom_class: custom_class}), do: " #{custom_class}"
  def get_custom_class(_), do: ""
end
