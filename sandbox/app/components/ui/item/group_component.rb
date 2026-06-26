# frozen_string_literal: true

module Ui
  module Item
    class GroupComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "list")
          attrs[:class] = class_names("group/item-group flex flex-col", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "item-group")
        end)
      end
    end
  end
end
