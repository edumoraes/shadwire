# frozen_string_literal: true

module Ui
  module Alert
    # The alert's heading line.
    class TitleComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **title_attrs)
      end

      private

      def title_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("line-clamp-1 min-h-4 font-medium tracking-tight", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "alert-title")
        end
      end
    end
  end
end
