# frozen_string_literal: true

module Ui
  # A slide carousel driven by the ui-carousel controller. Compose a
  # `Ui::Carousel::ContentComponent` of `ItemComponent`s plus
  # `PreviousComponent`/`NextComponent` controls. Arrow keys also navigate.
  class CarouselComponent < UiComponent
    def initialize(orientation: :horizontal, class_name: nil, **attrs)
      @orientation = orientation
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **carousel_attrs)
    end

    private

    def carousel_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:role] = attrs.fetch(:role, "region")
        attrs[:tabindex] = attrs.fetch(:tabindex, "0")
        attrs[:aria] = { roledescription: "carousel" }.merge(attrs.fetch(:aria, {}))
        attrs[:class] = class_names("relative", @class_name)
        attrs[:data] = carousel_data(attrs[:data])
      end
    end

    def carousel_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "carousel"
        data[:orientation] = @orientation.to_s
        data[:controller] = append_token(data[:controller], "ui-carousel")
        data[:ui_carousel_orientation_value] = @orientation.to_s
        data[:action] = append_token(data[:action], "keydown->ui-carousel#keydown")
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
