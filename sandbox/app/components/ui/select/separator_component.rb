# frozen_string_literal: true

module Ui
  module Select
    class SeparatorComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(**separator_attrs)
      end

      private

      def separator_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "separator")
          attrs[:class] = class_names("-mx-1 my-1 h-px bg-border", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "select-separator")
        end
      end
    end
  end
end
