# frozen_string_literal: true

module Ui
  module Pagination
    class ContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.ul(content, **content_attrs)
      end

      private

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("flex flex-row items-center gap-1", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "pagination-content")
        end
      end
    end
  end
end
