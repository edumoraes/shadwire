# frozen_string_literal: true

module Ui
  module Sheet
    # The ui-dialog controller links this element to the <dialog> through
    # aria-labelledby when it opens.
    class TitleComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.h2(content, **title_attrs)
      end

      private

      def title_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("font-semibold text-foreground", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "sheet-title")
        end
      end
    end
  end
end
