# frozen_string_literal: true

module Ui
  module Sidebar
    # Sticky-ish top region of the sidebar (logo, switcher, search).
    class HeaderComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **header_attrs)
      end

      private

      def header_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("flex flex-col gap-2 p-2", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-header")
        end
      end
    end
  end
end
