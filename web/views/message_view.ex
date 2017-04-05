defmodule UcxChat.MessageView do
  use UcxChat.Web, :view
  import Phoenix.HTML.Tag, only: [content_tag: 2, content_tag: 3, tag: 1]
  import Ecto.Query, except: [select: 3]

  alias UcxChat.{Message, Subscription, Repo, AttachmentService}
  alias UcxChat.ServiceHelpers, as: Helpers

  require Logger

  def get_reaction_people(reaction, user) do
    UcxChat.ReactionService.get_reaction_people_names(reaction, user)
  end

  def file_upload_allowed_media_types do
    ""
  end

  def get_not_subscribed_templ(_mb) do
    %{}
  end

  def get_message_wrapper_opts(msg, user) do
    cls =
      ~w(get_sequential get_system get_t get_own get_is_temp get_chat_opts get_custom_class get_new_day)a
      |> Enum.reduce("message background-transparent-dark-hover", fn fun, acc ->
        acc <> apply(__MODULE__, fun, [msg, user])
      end)
    attrs = [
      id: msg.id,
      class: cls,
      "data-username": msg.user.username,
      "data-groupable": msg.is_groupable,
      "data-date": format_date(msg.updated_at, user),
      "data-timestamp": msg.timestamp
    ]
    Phoenix.HTML.Tag.tag(:li, attrs)
  end
  def format_date(%{updated_at: dt}, user) do
    Helpers.format_date tz_offset(dt, user)
  end
  def format_date(dt, user) do
    Helpers.format_date tz_offset(dt, user)
  end
  def format_timestamp(dt, _user) do
    Message.format_timestamp dt
  end
  def format_time(%{updated_at: dt}, user) do
    format_time dt, user
  end
  def format_time(dt, user) do
    Helpers.format_time tz_offset(dt, user)
  end
  def format_date_time(%{updated_at: dt}, user) do
    format_date_time dt, user
  end

  def format_date_time(%Ecto.DateTime{} = dt, user) do
    dt
    |> Ecto.DateTime.to_erl
    |> NaiveDateTime.from_erl!
    |> format_date_time(user)
  end
  def format_date_time(nil, _), do: ""

  def format_date_time(dt, user) do
    Helpers.format_date_time tz_offset(dt, user)
  end

  defp tz_offset(dt, user) do
    Timex.shift(dt, hours: user.tz_offset || 0)
  end

  def avatar_from_username(_msg), do: false
  def emoji(_msg) do
    false
  end
  def get_username(msg), do: msg.user.username
  def get_users_typing(_msg), do: []
  def get_users_typing(_msg, _cmd), do: []
  def alias?(_msg), do: false
  def role_tags(message) do
    if UcxChat.Settings.display_roles() do
      message.user_id
      |> Helpers.get_user!
      |> UcxChat.User.tags(message.channel_id)
    else
      []
    end
  end
  def is_bot(_msg), do: false
  def get_date_time(msg, user), do: format_date_time(msg, user)
  def get_time(msg, user), do: format_time(msg, user)
  def is_private(%{type: "p"}), do: true
  def is_private(_msg), do: false
  def hide_cog(_msg), do: ""
  def attachments(_msg), do: []
  def hide_action_links(_msg), do: " hidden"
  def action_links(_msg), do: []
  def hide_reactions(msg) do
    if msg.reactions == [], do: " hidden", else: ""
  end
  def reactions(_msg), do: []
  def mark_user_reaction(_reaction), do: ""
  def render_emoji(_emoji), do: ""
  def has_oembed(_msg), do: false
  def edited(%{edited_id: edited_id} = msg, user) when not is_nil(edited_id) do
    %{
      edit_time: format_date_time(msg, user),
      edited_by: msg.edited_by.username,
    }
  end
  def edited(_msg, _), do: false


  def get_new_day(%{new_day: true}, _), do: " new-day"
  def get_new_day(_, _), do: ""
  def get_sequential(%{sequential: true}, _), do: " sequential"
  def get_sequential(_, _), do: ""
  def get_system(%{system: true}, _), do: " system"
  def get_system(_, _), do: ""
  def get_t(%{t: t}, _), do: "#{t}"
  def get_t(_, _), do: ""
  def get_own(%{system: true}, _), do: ""
  def get_own(%{user_id: id}, %{id: id}), do: " own"
  def get_own(_, _), do: ""
  def get_is_temp(%{is_temp: is_temp}, _), do: "#{is_temp}"
  def get_is_temp(_, _), do: ""
  def get_chat_opts(%{chat_opts: chat_opts}, _), do: "#{chat_opts}"
  def get_chat_opts(_, _), do: ""
  def get_custom_class(%{custom_class: custom_class}, _), do: "#{custom_class}"
  def get_custom_class(_, _), do: ""

  def get_info_class(%{system: _}), do: "color-info-font-color"
  def get_info_class(_), do: ""

  def get_mb(chatd) do
    defaults =
      [:blocked?, :read_only?, :archived?, :allowed_to_send?, :subscribed?, :can_join?]
      |> Enum.map(&({&1, false}))
      |> Enum.into(%{})

    channel = chatd.channel
    private = channel.type != 0

    subscribed =
      Subscription
      |> where([s], s.channel_id == ^(chatd.channel.id) and s.user_id == ^(chatd.user.id))
      |> Repo.all
      |> case do
        [] -> false
        _ -> true
      end
    blocked = channel.blocked
    read_only = channel.read_only
    archived = channel.archived
    can_join = !(private or read_only or blocked or archived)
    nm = chatd.active_room[:display_name]
    symbol = if channel.type == 2, do: "@" <> nm, else: "#" <> nm
    settings =
      [
        blocked?: blocked, read_only?: read_only, archived?: archived,
        allowed_to_send?: !(blocked or read_only or archived),
        can_join?: can_join, subscribed?: subscribed, symbol: symbol
      ]
      |> Enum.into(defaults)

    config = UcxChat.Repo.one(UcxChat.Config)

    settings =
      [
        max_message_length: Settings.max_allowed_message_size(config),
        show_formatting_tips?: Settings.show_formatting_tips(config),
        show_file_upload?: AttachmentService.allowed?(channel),
      ]
      |> Enum.into(settings)

    if Application.get_env :ucx_chat, :defer, true do
      [:katex_syntax?, :show_mark_down?, :show_markdown_code?, :show_markdown?]
      # [:katex_syntax?, :show_mark_down?, :show_markdown_code?, :show_markdown?]
    else
      [:katex_syntax?,
       :show_sandstorm?, :show_location?, :show_mic?, :show_v_rec?,
       :show_mark_down?, :show_markdown_code?, :show_markdown?]
    end
    |> Enum.map(&({&1, true}))
    |> Enum.into(settings)
    # - if nst[:template] do
    # = render nst[:template]
    # - if nst[:can_join] do
    # = nst[:room_name]
    # - if nst[:join_code_required] do
  end

  def show_formatting_tips(%{show_formatting_tips?: true} = mb) do
    content_tag :div, class: "formatting-tips", "aria-hidden": "true", dir: "auto" do
      [
        show_markdown1(mb),
        show_markdown_code(mb),
        show_katax_syntax(mb),
        show_markdown2(mb)
      ]
    end
  end
  def show_formatting_tips(_), do: ""

  def show_katax_syntax(%{katex_syntax?: true}) do
    content_tag :span do
      content_tag :a, href: "https://github.com/Khan/KaTeX/wiki/Function-Support-in-KaTeX", target: "_blank" do
        "\[KaTex\]"
      end
    end
  end
  def show_katax_syntax(_), do: []

  def show_markdown1(%{show_mark_down?: true}) do
    [
      content_tag(:b, "*bold*"),
      content_tag(:i, "_italics_"),
      content_tag(:span, do: ["~", content_tag(:strike, "strike"), "~"])
    ]
  end
  def show_markdown1(_), do: []

  def show_markdown2(%{show_mark_down?: true}) do
    content_tag :q do
      [ hidden_br(), ">quote" ]
    end
  end
  def show_markdown2(_), do: []

  def show_markdown_code(%{show_markdown_code?: true}) do
    [
      content_tag(:code, [class: "code-colors inline"], do: "`inline_code`"),
      show_markdown_code1()
    ]
  end
  def show_markdown_code(_), do: []

  def show_markdown_code1 do
    content_tag :code, class: "code-colors inline" do
      [
        hidden_br(),
        "```",
        hidden_br(),
        content_tag :i,  class: "icon-level-down" do
        end,
        "multi",
        hidden_br(),
        content_tag :i,  class: "icon-level-down" do
        end,
        "line",
        hidden_br(),
        content_tag :i,  class: "icon-level-down" do
        end,
        "```"
      ]
    end
  end

  defp hidden_br do
    content_tag :span, class: "hidden-br" do
      tag :br
    end
  end

  def is_popup_open(%{open: true}), do: true
  def is_popup_open(_), do: false

  def get_popup_cls(_chatd) do
    ""
  end
  def get_loading(_chatd) do
    false
  end
  def get_popup_title(%{title: title}), do: title
  def get_popup_title(_), do: false

  def get_popup_data(%{data: data}), do: data
  def get_popup_data(_), do: false

  def format_message_body(message) do
    # Logger.warn "type: #{inspect message.type}, system: #{inspect message.system}, body: #{inspect message.body}"
    body = AutoLinker.link message.body || "", exclude_pattern: "```"
    quoted? = String.contains?(body, "```")
    body
    |> EmojiOne.shortname_to_image
    # |> String.replace("&lt;", "<")
    # |> String.replace("&gt;", ">")
    |> format_newlines(quoted?, message.system)
    |> UcxChat.SharedView.format_quoted_code(quoted?, message.system)
    |> raw
  end

  defp format_newlines(string, true, _), do: string
  defp format_newlines(string, _, true), do: string
  defp format_newlines(string, false, _), do: String.replace(string, "\n", "\n<br />\n")

  def message_cog_action_li(name, title, icon, extra \\ "") do
    #{}"reaction-message", "Reactions", "people-plus")
    opts = [class: "#{name} #{extra} message-action", title: title, "data-id": name]
    content_tag :li, opts do
      content_tag :i, class: "icon-#{icon}", "aria-label": title do
        ""
      end
    end
  end
end
