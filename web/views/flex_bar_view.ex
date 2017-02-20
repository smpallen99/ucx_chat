defmodule UcxChat.FlexBarView do
  use UcxChat.Web, :view
  # import Phoenix.HTML.Tag, only: [content_tag: 3, content_tag: 2]

  # "Showing: <b>1<b>, Online: 1, Total: 1 users"
  def get_clients_list_stats(clients) do
    showing = online = total = length(clients)
    Phoenix.HTML.Tag.content_tag :span do
      [
        "Showing: ",
        Phoenix.HTML.Tag.content_tag :b do
          showing
        end,
        ", Online: #{online}, Total: #{total} users"
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
             opts <- if(field[:disabled], do: [{:disabled, true}|opts], else: opts),
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
