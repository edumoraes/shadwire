# frozen_string_literal: true

module Ui
  module Accordion
    class ContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(**content_attrs) do
          tag.div(content, class: "pt-0 pb-4")
        end
      end

      private

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "region")
          attrs[:hidden] = true unless attrs.key?(:hidden)
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "accordion-content"
          data[:state] = data.fetch(:state, "closed")
          data[:ui_accordion_target] = append_token(data[:ui_accordion_target], "content")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "overflow-hidden text-sm data-[state=closed]:animate-accordion-up data-[state=open]:animate-accordion-down"
      end
    end
  end
end
