# frozen_string_literal: true

module Ui
  class ScrollAreaComponent < UiComponent
    ORIENTATIONS = [ :vertical, :horizontal ].freeze

    def initialize(scrollbars: [ :vertical ], class_name: nil, **attrs)
      @scrollbars = normalize_scrollbars(scrollbars)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(**scroll_area_attrs) do
        safe_join([ viewport_html, *scrollbar_html, corner_html ].compact)
      end
    end

    private

    def viewport_html
      render Ui::ScrollArea::ViewportComponent.new do
        render Ui::ScrollArea::ContentComponent.new do
          content
        end
      end
    end

    def scrollbar_html
      @scrollbars.map do |orientation|
        render Ui::ScrollArea::ScrollbarComponent.new(orientation:)
      end
    end

    def corner_html
      return unless @scrollbars.sort == ORIENTATIONS.sort

      render Ui::ScrollArea::CornerComponent.new
    end

    def scroll_area_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("relative overflow-hidden", @class_name)
        attrs[:data] = scroll_area_data(attrs[:data])
      end
    end

    def scroll_area_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "scroll-area"
        data[:controller] = append_token(data[:controller], "ui-scroll-area")
      end
    end

    def normalize_scrollbars(scrollbars)
      normalized = Array.wrap(scrollbars).filter_map do |orientation|
        key = orientation.presence&.to_sym
        key if ORIENTATIONS.include?(key)
      end

      normalized.presence || [ :vertical ]
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
