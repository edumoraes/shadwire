# frozen_string_literal: true

module Ui
  module HoverCard
    # The element that opens the hover card. Defaults to a link (`tag: :a`);
    # pass `tag: :button` for an interactive control.
    class TriggerComponent < UiComponent
      def initialize(tag: :a, class_name: nil, **attrs)
        @tag = tag
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag, content, **trigger_attrs)
      end

      private

      def trigger_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(@class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "hover-card-trigger"
            data[:ui_hover_card_target] = append_token(data[:ui_hover_card_target], "trigger")
          end
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
