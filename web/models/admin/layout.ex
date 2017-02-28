defmodule UcxChat.Config.Layout do
  use UcxChat.Web, :model

  embedded_schema do
    field :display_roles, :boolean, default: true
    field :merge_private_groups, :boolean, default: true
    field :user_full_initials_for_avatars, :boolean, default: false
    field :body_font_family, :string, default: "-apple-system, BlinkMacSystemFont, Roboto, 'Helvetica Neue', Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Meiryo UI'"
    field :content_home_title, :string, default: "Home"
    field :content_home_body, :string, default: "Welcome to Ucx Chat <br> Go to APP SETTINGS -> Layout to customize this intro."
    field :content_side_nav_footer, :string, default: ~s(<img src="/assets/logo" />)
  end

  @fields [
    :display_roles,
    :merge_private_groups,
    :user_full_initials_for_avatars,
    :body_font_family,
    :content_home_title,
    :content_home_body,
    :content_side_nav_footer,
  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @fields)
  end
end
