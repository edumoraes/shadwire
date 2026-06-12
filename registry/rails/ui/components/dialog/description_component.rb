# frozen_string_literal: true

module Ui
  module Dialog
    # The ui-dialog controller links this element to the <dialog> through
    # aria-describedby when it opens.
    class DescriptionComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.p(content, **description_attrs)
      end

      private

      def description_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("text-sm text-muted-foreground", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "dialog-description")
        end
      end
    end
  end
end
