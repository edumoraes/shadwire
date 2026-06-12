# frozen_string_literal: true

module Ui
  # A tooltip that opens on hover or focus. The hover/focus listeners live on
  # the root so the tooltip stays open while the pointer moves onto the
  # content, which is rendered inside this element.
  class TooltipComponent < UiComponent
    def initialize(open_delay: 300, class_name: nil, **attrs)
      @open_delay = open_delay
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **tooltip_attrs)
    end

    private

    def tooltip_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("relative inline-block w-fit", @class_name)
        attrs[:data] = tooltip_data(attrs[:data])
      end
    end

    def tooltip_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "tooltip"
        data[:controller] = append_token(data[:controller], "ui-tooltip")
        data[:ui_tooltip_open_delay_value] = @open_delay
        data[:action] = append_token(
          data[:action],
          "mouseenter->ui-tooltip#scheduleShow mouseleave->ui-tooltip#hide " \
          "focusin->ui-tooltip#show focusout->ui-tooltip#hide keydown.esc->ui-tooltip#hide"
        )
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
