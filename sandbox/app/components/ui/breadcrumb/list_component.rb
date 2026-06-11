# frozen_string_literal: true

module Ui
  module Breadcrumb
    class ListComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.ol(content, **list_attrs)
      end

      private

      def list_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(
            "flex flex-wrap items-center gap-1.5 break-words text-sm text-muted-foreground sm:gap-2.5",
            @class_name
          )
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "breadcrumb-list")
        end
      end
    end
  end
end
