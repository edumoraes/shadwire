# frozen_string_literal: true

module Ui
  module Table
    class FooterComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.tfoot(content, **footer_attrs)
      end

      private

      def footer_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("border-t bg-muted/50 font-medium [&>tr]:last:border-b-0", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "table-footer")
        end
      end
    end
  end
end
