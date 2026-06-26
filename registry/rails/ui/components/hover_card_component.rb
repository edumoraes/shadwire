# frozen_string_literal: true

module Ui
  # Rich content that opens when a trigger is hovered or focused. Like the
  # tooltip, the hover/focus listeners live on the root so the pointer can move
  # onto the card. Compose a `Ui::HoverCard::TriggerComponent` and `ContentComponent`.
  class HoverCardComponent < UiComponent
    def initialize(open_delay: 700, close_delay: 300, class_name: nil, **attrs)
      @open_delay = open_delay
      @close_delay = close_delay
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **hover_card_attrs)
    end

    private

    def hover_card_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("relative inline-block w-fit", @class_name)
        attrs[:data] = hover_card_data(attrs[:data])
      end
    end

    def hover_card_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "hover-card"
        data[:controller] = append_token(data[:controller], "ui-hover-card")
        data[:ui_hover_card_open_delay_value] = @open_delay
        data[:ui_hover_card_close_delay_value] = @close_delay
        data[:action] = append_token(
          data[:action],
          "mouseenter->ui-hover-card#scheduleOpen mouseleave->ui-hover-card#scheduleClose " \
          "focusin->ui-hover-card#scheduleOpen focusout->ui-hover-card#scheduleClose"
        )
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
