# frozen_string_literal: true

module Ui
  module Sidebar
    # Holds a group's menu(s).
    class GroupContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **group_content_attrs)
      end

      private

      def group_content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("w-full text-sm", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-group-content")
        end
      end
    end
  end
end
