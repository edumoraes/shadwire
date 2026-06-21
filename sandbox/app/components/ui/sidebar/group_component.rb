# frozen_string_literal: true

module Ui
  module Sidebar
    # A labelled section within the sidebar content.
    class GroupComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **group_attrs)
      end

      private

      def group_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("relative flex w-full min-w-0 flex-col p-2", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-group")
        end
      end
    end
  end
end
