# frozen_string_literal: true

module Ui
  module DropdownMenu
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
          attrs[:role] = attrs.fetch(:role, "group")
          attrs[:class] = class_names(@class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "dropdown-menu-group")
        end
      end
    end
  end
end
