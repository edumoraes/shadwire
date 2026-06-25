# frozen_string_literal: true

module Ui
  module Command
    class SeparatorComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(**html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "separator")
          attrs[:class] = class_names("-mx-1 h-px bg-border", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "command-separator")
        end)
      end
    end
  end
end
