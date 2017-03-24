defmodule UcxChat.AdminView do
  use UcxChat.Web, :view
  alias UcxChat.{User}

  def collapsable_section(title, fun) do
    content_tag :div, class: "section section-collapsed" do
      [
        content_tag :div, class: "section-title" do
          [
            content_tag :div, class: "section-title-text" do
              title
            end,
            content_tag :div, class: "section-title-right" do
              content_tag :button, class: "button primary expand" do
                content_tag :span do
                  ~g"Expand"
                end
              end
            end
          ]
        end,
        content_tag :div, class: "section-content border-component-color" do
          fun.(nil)
        end
      ]
    end
  end

  def reset_section_settings do
    content_tag :div, class: "input-line double-col" do
      [
        content_tag :label, class: "setting-label" do
          ~g"Reset section settings"
        end,
        content_tag :div, class: "setting-field" do
          content_tag :button, class: "reset-group button danger" do
            ~g"Reset"
          end
        end
      ]
    end
  end

  def text_input_line(f, _item, field, title, opts \\ []) do
    type = opts[:type] || :text
    description = opts[:description]

    content_tag :div, class: "input-line double-col" do
      [
        content_tag :label, class: "setting-label" do
          title
        end,
        content_tag :div, class: "setting-field" do
          f
          |> text_input(field, class: "input-monitor", type: type)
          |> do_description(description)
        end
      ]
    end
  end

  def textarea_input_line(f, _item, field, title, opts \\ []) do
    type = opts[:type] || :text
    description = opts[:description]

    content_tag :div, class: "input-line double-col" do
      [
        content_tag :label, class: "setting-label" do
          title
        end,
        content_tag :div, class: "setting-field" do
          f
          |> textarea(field, class: "input-monitor", type: type)
          |> do_description(description)
        end
      ]
    end
  end

  defp do_description(tag, nil), do: tag
  defp do_description(tag, description) when is_list(tag) do
    tag ++ [
      content_tag :div, class: "settings-description" do
        description
      end
    ]
  end
  defp do_description(tag, description) do
    [
      tag,
      content_tag :div, class: "settings-description" do
        description
      end
    ]
  end

  def radio_button_line(f, item, field, title, opts \\ []) do
    checked = Map.get(item, field)
    description = opts[:description]
    content_tag :div, class: "input-line double-col" do
      [
        content_tag :label, class: "setting-label" do
          title
        end,
        content_tag :div, class: "setting-field" do
          [
            content_tag :label do
              [
                radio_button(f, field, "1", checked: checked, class: "input-monitor"),
                "True"
              ]
            end,
            content_tag :label do
              [
                radio_button(f, field, "0", checked: !checked, class: "input-monitor"),
                "False"
              ]
            end
          ]
          |> do_description(description)
        end
      ]
    end
  end

  def room_type(0), do: ~g"Channel"
  def room_type(1), do: ~g"Private Group"
  def room_type(2), do: ~g"Direct Message"

  def get_admin_flex_tabs(mode) do
    # user = chatd.user
    # user_mode = chatd.channel.type == 2
    # config = Settings.config
    UcxChat.FlexAdminService.default_settings(mode)
  end

  def render_user_action_button(user, "admin") do
    if User.has_role? user, "admin", nil do
      render "user_action_buttons.html", opts: %{type: :danger, action: "remove-admin", icon: :shield, label: ~g(REMOVE ADMIN)}
    else
      render "user_action_buttons.html", opts: %{type: :secondary, action: "make-admin", icon: :shield, label: ~g(MAKE ADMIN)}
    end
  end

  def render_user_action_button(user, "activate") do
    if user.active do
      render "user_action_buttons.html", opts: %{type: :danger, action: "deactivate", icon: :block, label: ~g(DEACTIVATE)}
    else
      render "user_action_buttons.html", opts: %{type: :secondary, action: "activate", icon: "ok-circled", label: ~g(ACTIVATE)}
    end
  end

  def render_user_action_button(_user, "edit") do
    render "user_action_buttons.html", opts: %{type: :primary, action: "edit-user", icon: :edit, label: ~g(EDIT)}
  end

  def render_user_action_button(_user, "delete") do
    render "user_action_buttons.html", opts: %{type: :danger, action: "delete", icon: :trash, label: ~g(DELETE)}
  end

  def admin_type_label(%{type: 0}), do: ~g(Channel)
  def admin_type_label(%{type: 1}), do: ~g(Private Group)
  def admin_type_label(%{type: 2}), do: ~g(Direct Message)

  def admin_state_label(%{archived: true}), do: ~g(Archived)
  def admin_state_label(_), do: ~g(Active)

  def admin_label(channel, field) do
    channel
    |> Map.get(field)
    |> do_admin_label
  end
  def admin_label(item), do: do_admin_label(item)

  defp do_admin_label(true), do: ~g(True)
  defp do_admin_label(false), do: ~g(False)
end
