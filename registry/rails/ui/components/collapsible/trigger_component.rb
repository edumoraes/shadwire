# frozen_string_literal: true

module Ui
  module Collapsible
    # The button that expands/collapses the region. Defaults to a bare button so
    # it can wrap arbitrary trigger content.
    class TriggerComponent < UiComponent
      def initialize(open: false, class_name: nil, **attrs)
        @open = open
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.button(content, **trigger_attrs)
      end

      private

      def trigger_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = attrs.fetch(:type, "button")
          attrs[:class] = class_names(@class_name)
          attrs[:aria] = { expanded: @open ? "true" : "false" }.merge(attrs.fetch(:aria, {}))
          attrs[:data] = trigger_data(attrs[:data])
        end
      end

      def trigger_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "collapsible-trigger"
          data[:state] = @open ? "open" : "closed"
          data[:ui_collapsible_target] = append_token(data[:ui_collapsible_target], "trigger")
          data[:action] = append_token(data[:action], "click->ui-collapsible#toggle")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
