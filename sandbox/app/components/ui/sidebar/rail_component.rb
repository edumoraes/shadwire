# frozen_string_literal: true

module Ui
  module Sidebar
    # A thin hit area along the sidebar's inner edge that toggles collapse on
    # click. Hidden on small screens; shown from `sm` up.
    class RailComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.button(**rail_attrs)
      end

      private

      def rail_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = attrs.fetch(:type, "button")
          attrs[:tabindex] = attrs.fetch(:tabindex, "-1")
          attrs[:title] = attrs.fetch(:title, "Toggle Sidebar")
          attrs[:aria] = { label: "Toggle Sidebar" }.merge(attrs.fetch(:aria, {}))
          attrs[:class] = rail_classes
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "sidebar-rail"
            data[:action] = append_token(data[:action], "click->ui-sidebar#toggle")
          end
        end
      end

      def rail_classes
        class_names(
          "absolute inset-y-0 z-20 hidden w-4 -translate-x-1/2 transition-all ease-linear sm:flex",
          "after:absolute after:inset-y-0 after:left-1/2 after:w-[2px] hover:after:bg-sidebar-border",
          "group-data-[side=left]:-right-4 group-data-[side=right]:left-0",
          "group-data-[collapsible=offcanvas]:translate-x-0 group-data-[collapsible=offcanvas]:hover:bg-sidebar",
          @class_name
        )
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
