defmodule UcxChat.FlexBarView do
  use UcxChat.Web, :view
  # import Phoenix.HTML.Tag, only: [content_tag: 3, content_tag: 2]

  # "Showing: <b>1<b>, Online: 1, Total: 1 users"
  def get_users_list_stats(users, user_info) do
    total = user_info.total_count
    showing = online = length(users)
    Phoenix.HTML.Tag.content_tag :span, class: ".stats" do
      [
        ~g(Showing: ),
        Phoenix.HTML.Tag.content_tag :b, class: "showing-cnt" do
          showing
        end,
        ", ",
        ~g(Online: ),
        Phoenix.HTML.Tag.content_tag :span, class: "online-cnt" do
          online
        end,
        ", ",
        ~g(Total: ),
        Phoenix.HTML.Tag.content_tag :span, class: "total-cnt" do
          total
        end,
        ~g( users)
      ]
    end
    # |> Phoenix.HTML.safe_to_string
  end

  def get_li_class(item, class) do
    with acc <- [to_string(class) | ~w(message background-transparent-dark-hover)],
         acc <- if(item[:own], do: ["own"|acc], else: acc),
         acc <- if(item[:new_day], do: ["new-day"|acc], else: acc) do
      Enum.join(acc, " ")
    end
  end

  def flex_form_line(field) do
    content_tag :li, class: field[:type] do
      [
        content_tag :label do
          field[:label]
        end,
        content_tag :div, class: "setting-block" do
          flex_form_input field[:type], field
        end
      ]
    end
  end

  def flex_form_input(:boolean, field) do
    content_tag :div, class: "input checkbox toggle" do
      [
        with opts <- [class: field[:name], type: :checkbox, name: field[:name], id: field[:name]],
             opts <- if(field[:read_only], do: [{:disabled, true}|opts], else: opts),
             opts <- if(field[:value], do: [{:checked, true}|opts], else: opts) do
          content_tag :input, opts do
          end
        end,
        content_tag :label, for: field[:name] do
        end
      ]
    end
  end

  def flex_form_input(:text, %{read_only: true} = field) do
    content_tag :span, class: "current-setting", "data-edit": "false" do
      field[:value]
    end
  end

  def flex_form_input(:text, field) do
    [
      content_tag :span, class: "current-setting", "data-edit": field[:name] do
        field[:value]
      end,
      content_tag :button, class: "button edit", type: "button" do
        content_tag :i, class: "icon-pencil", "data-edit": field[:name] do
        end
      end
    ]
  end

  def get_user_card_class(%{admin: true}) do
    "user-view"
  end
  def get_user_card_class(user_info) do
    hidden = hidden_on_nil(user_info[:user_mode], "animated-")
    "user-view animated #{hidden}"
    "user-view animated"
  end

  def option_tag(schema, field, id, text) do
    selected = if Map.get(schema, field) == id, do: [selected: :selected], else: []
    content_tag :option, [value: id] ++ selected do
      text
    end
  end

  def radio_tag(schema, field, id, text, opts \\ []) do
    name = opts[:name] || field
    checked = if Map.get(schema, field) == id, do: [checked: :true], else: []
    content_tag :label do
      [
        tag(:input, [type: :radio, name: name, value: id] ++ checked),
        text
      ]
    end
  end

  def file_icon(:image), do: "icon-picture"
  def file_icon(:video), do: "icon-video"
  def file_icon(:audio), do: "icon-play"
  def file_icon(_), do: "icon-docs"

              #   = radio_tag(settings, :desktop, id, text)
              # %label
              #   %input(type="radio" name="desktopNotifications" value="all" checked="{{$eq desktopNotifications 'all'}}")= ~g"All_messages"
  # def notification_radio_group(data, field, option) do
  #   settings = data[:settings]
  #   checked = if []
  #   content_tag :label do
  #     [
  #       div(:input, [type: :radio, name: "settings[#{field}]", value: elem(option, 0)] ++ checked),
  #       elem(option, 1)
  #     ]
  #   end
  # end

  # %li.text
  #   %label Name
  #   .setting-block
  #     %span.current-setting(data-edit="name")= @channel.name
  #     %button.button.edit(type="button")
  #       %i.icon-pencil(data-edit="name")
  # %li.markdown
  #   %label Topic
  #   .setting-block
  #     %span.current-setting(data-edit="topic")= @channel.topic
  #       %button.button.edit(type="button")
  #         %i.icon-pencil(data-edit="topic")
  # %li.text
  #   %label Description
  #   .setting-block
  #     %span.current-setting(data-edit="description")= @channel.description
  #       %button.button.edit(type="button")
  #         %i.icon-pencil(data-edit="description")
  # %li.boolean
  #    %label Private
  #   .setting-block
  #     .input.checkbox.toggle
  #       = chat_checkbox_input("t", :private, @channel)
  #       %input#t(type="checkbox" name="t" disabled="false" selected="true")
  #       %label(for="t")
  # %li.boolean
  #   %label Read Only
  #   .setting-block
  #     .input.checkbox.toggle
  #       %input#to(type="checkbox" name="to" disabled="false")
  #       %label(for="to")
end
