# frozen_string_literal: true

module Ui
  # A drawer that slides in from an edge. Built on the native <dialog> via the
  # ui-drawer controller (focus trap, Escape, drag-to-dismiss). Compose a
  # `Ui::Drawer::TriggerComponent` and `ContentComponent`.
  class DrawerComponent < UiComponent
    def initialize(close_on_backdrop: true, class_name: nil, **attrs)
      @close_on_backdrop = close_on_backdrop
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **drawer_attrs)
    end

    private

    def drawer_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(@class_name)
        attrs[:data] = drawer_data(attrs[:data])
      end
    end

    def drawer_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "drawer"
        data[:controller] = append_token(data[:controller], "ui-drawer")
        data[:ui_drawer_close_on_backdrop_value] = @close_on_backdrop
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
