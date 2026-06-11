# frozen_string_literal: true

module Ui
  module Breadcrumb
    class PageComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.span(content, **page_attrs)
      end

      private

      def page_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "link")
          attrs[:class] = class_names("font-normal text-foreground", @class_name)
          attrs[:aria] = { disabled: "true", current: "page" }.merge(attrs.fetch(:aria, {}))
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "breadcrumb-page")
        end
      end
    end
  end
end
