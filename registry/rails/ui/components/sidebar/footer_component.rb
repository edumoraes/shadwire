# frozen_string_literal: true

module Ui
  module Sidebar
    # Bottom region of the sidebar (user menu, secondary actions).
    class FooterComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **footer_attrs)
      end

      private

      def footer_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("flex flex-col gap-2 p-2", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-footer")
        end
      end
    end
  end
end
