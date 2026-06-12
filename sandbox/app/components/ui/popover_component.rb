# frozen_string_literal: true

module Ui
  class PopoverComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **popover_attrs)
    end

    private

    def popover_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("relative w-fit", @class_name)
        attrs[:data] = popover_data(attrs[:data])
      end
    end

    def popover_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "popover"
        data[:controller] = append_token(data[:controller], "ui-popover")
        data[:action] = append_token(
          data[:action],
          "click@window->ui-popover#outsideClick keydown.esc@window->ui-popover#closeOnEscape"
        )
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
