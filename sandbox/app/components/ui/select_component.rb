# frozen_string_literal: true

module Ui
  # A custom select following the APG select-only combobox pattern. Submits
  # through a hidden input, so use it inside `form_with` with `name:`. Note
  # that the browser's native `required` validation does not apply to a hidden
  # input — validate the value server-side.
  class SelectComponent < UiComponent
    def initialize(name: nil, value: nil, placeholder: nil, disabled: false, class_name: nil, **attrs)
      @name = name
      @value = value
      @placeholder = placeholder
      @disabled = disabled
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(**select_attrs) do
        safe_join([ hidden_input, content ].compact)
      end
    end

    private

    def select_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("relative w-fit", @class_name)
        attrs[:data] = select_data(attrs[:data])
      end
    end

    def select_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "select"
        data[:controller] = append_token(data[:controller], "ui-select")
        data[:ui_select_value_value] = @value.to_s
        data[:ui_select_placeholder_value] = @placeholder.to_s
        data[:action] = append_token(data[:action], "click@window->ui-select#outsideClick")
      end
    end

    def hidden_input
      tag.input(type: "hidden", name: @name, value: @value, data: { ui_select_target: "input" })
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
