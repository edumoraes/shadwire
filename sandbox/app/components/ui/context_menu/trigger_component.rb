# frozen_string_literal: true

module Ui
  module ContextMenu
    # The area that opens the menu on right-click (contextmenu).
    class TriggerComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(@class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "context-menu-trigger"
            data[:action] = append_token(data[:action], "contextmenu->ui-context-menu#open")
          end
        end)
      end

      private

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
