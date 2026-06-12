# frozen_string_literal: true

module Ui
  module Select
    # Holds the selected option's label. The ui-select controller fills it
    # with the chosen label or the placeholder on connect and on change.
    class ValueComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.span(content, **value_attrs)
      end

      private

      def value_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("pointer-events-none line-clamp-1", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "select-value"
            data[:ui_select_target] = append_token(data[:ui_select_target], "value")
          end
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
