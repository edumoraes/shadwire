# frozen_string_literal: true

module Ui
  module Breadcrumb
    class LinkComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.a(content, **link_attrs)
      end

      private

      def link_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("transition-colors hover:text-foreground", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "breadcrumb-link")
        end
      end
    end
  end
end
