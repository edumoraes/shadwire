# frozen_string_literal: true

module Ui
  module Sidebar
    # The scrollable middle region holding the groups/menus.
    class ContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **content_attrs)
      end

      private

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(
            "flex min-h-0 flex-1 flex-col gap-2 overflow-auto group-data-[collapsible=icon]:overflow-hidden",
            @class_name
          )
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-content")
        end
      end
    end
  end
end
