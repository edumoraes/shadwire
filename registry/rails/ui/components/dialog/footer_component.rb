# frozen_string_literal: true

module Ui
  module Dialog
    class FooterComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **footer_attrs)
      end

      private

      def footer_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("flex flex-col-reverse gap-2 sm:flex-row sm:justify-end", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "dialog-footer")
        end
      end
    end
  end
end
