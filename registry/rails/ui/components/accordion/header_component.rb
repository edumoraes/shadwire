# frozen_string_literal: true

module Ui
  module Accordion
    class HeaderComponent < UiComponent
      def initialize(tag: :h3, class_name: nil, **attrs)
        @tag = tag
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag, content, **header_attrs)
      end

      private

      def header_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("flex", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "accordion-header")
        end
      end
    end
  end
end
