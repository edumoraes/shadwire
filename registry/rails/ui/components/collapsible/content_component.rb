# frozen_string_literal: true

module Ui
  module Collapsible
    # The region revealed by the trigger. Hidden until opened; animates its
    # height via the measured `--radix-collapsible-content-height` variable.
    class ContentComponent < UiComponent
      def initialize(open: false, class_name: nil, **attrs)
        @open = open
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **content_attrs)
      end

      private

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:hidden] = true unless @open || attrs.key?(:hidden)
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "collapsible-content"
          data[:state] = @open ? "open" : "closed"
          data[:ui_collapsible_target] = append_token(data[:ui_collapsible_target], "content")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "overflow-hidden text-sm data-[state=closed]:animate-collapsible-up data-[state=open]:animate-collapsible-down"
      end
    end
  end
end
