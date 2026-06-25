# frozen_string_literal: true

module Ui
  module Drawer
    class HeaderComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("flex flex-col gap-1.5 text-center sm:text-left", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "drawer-header")
        end)
      end
    end
  end
end
