# frozen_string_literal: true

module Ui
  # A disclosure that expands/collapses a single region. Compose a
  # `Ui::Collapsible::TriggerComponent` and `ContentComponent` inside it; pass
  # `open: true` to start expanded.
  class CollapsibleComponent < UiComponent
    def initialize(open: false, class_name: nil, **attrs)
      @open = open
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **collapsible_attrs)
    end

    private

    def collapsible_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(@class_name)
        attrs[:data] = collapsible_data(attrs[:data])
      end
    end

    def collapsible_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "collapsible"
        data[:controller] = append_token(data[:controller], "ui-collapsible")
        data[:ui_collapsible_open_value] = @open
        data[:state] = @open ? "open" : "closed"
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
