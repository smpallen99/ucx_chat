defmodule UcxChat.Config.Message do
  use UcxChat.Web, :model

  embedded_schema do
    field :allow_message_editing, :boolean, default: true
    field :block_message_editing_after, :integer, default: 0
    field :block_message_deleting_after, :integer, default: 0
    field :allow_message_deleting, :boolean, default: true
    field :show_edited_status, :boolean, default: true
    field :show_deleted_status, :boolean, default: false
    field :allow_bad_words_filtering, :boolean, default: false
    field :add_bad_words_to_blacklist, :string, default: ""
    field :max_channel_size_for_all_message, :integer, default: 0
    field :max_allowed_message_size, :integer, default: 5000
    field :show_formatting_tips, :boolean, default: true
    field :grouping_period_seconds, :integer, default: 300
    field :embed_link_previews, :boolean, default: true
    field :disable_embedded_for_users, :string, default: ""
    field :embeded_ignore_hosts, :string, default: "localhost, 127.0.0.1, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16"
    field :time_format, :string, default: "LT"
    field :date_format, :string, default: "LL"
    field :hide_user_join, :boolean, default: false
    field :hide_user_leave, :boolean, default: false
    field :hide_user_removed, :boolean, default: false
    field :hide_user_added, :boolean, default: false
    field :hide_user_muted, :boolean, default: false
    field :allow_message_pinning, :boolean, default: true
    field :allow_message_staring, :boolean, default: true
    field :allow_message_snippeting, :boolean, default: false
    field :autolinker_strip_prefix, :boolean, default: false
    field :autolinker_scheme_urls, :boolean, default: true
    field :autolinker_www_urls, :boolean, default: true
    field :autolinker_tld_urls, :boolean, default: true
    field :autolinker_url_regexl, :string, default: "(://|www\.).+"
    field :autolinker_email, :boolean, default: true
    field :autolinker_phone, :boolean, default: true

  end

  @fields [
    :allow_message_editing, :block_message_editing_after, :block_message_deleting_after,
    :allow_message_deleting, :show_edited_status, :show_deleted_status, :allow_bad_words_filtering,
    :add_bad_words_to_blacklist, :max_channel_size_for_all_message, :max_allowed_message_size,
    :show_formatting_tips, :grouping_period_seconds, :embed_link_previews, :disable_embedded_for_users,
    :embeded_ignore_hosts, :time_format, :date_format, :hide_user_join, :hide_user_leave,
    :hide_user_removed, :hide_user_added, :hide_user_muted, :allow_message_pinning, :allow_message_staring,
    :allow_message_snippeting, :autolinker_strip_prefix, :autolinker_scheme_urls, :autolinker_www_urls,
    :autolinker_tld_urls, :autolinker_url_regexl, :autolinker_email, :autolinker_phone,
  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
    # |> validate_required(@fields)
  end

end
