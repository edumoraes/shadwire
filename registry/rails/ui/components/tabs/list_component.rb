# frozen_string_literal: true

module Ui
  module Tabs
    class ListComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **list_attrs)
      end

      private

      def list_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "tablist")
          attrs[:class] = class_names(
            "inline-flex h-9 w-fit items-center justify-center rounded-lg bg-muted p-[3px] text-muted-foreground",
            @class_name
          )
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "tabs-list")
        end
      end
    end
  end
end
