# frozen_string_literal: true

module Ui
  module Alert
    # The alert's body text. Holds one line or several `<p>`.
    class DescriptionComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **description_attrs)
      end

      private

      def description_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(
            "grid justify-items-start gap-1 text-sm text-muted-foreground [&_p]:leading-relaxed",
            @class_name
          )
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "alert-description")
        end
      end
    end
  end
end
