# frozen_string_literal: true

module Ui
  module Tabs
    class TriggerComponent < UiComponent
      def initialize(value:, disabled: false, class_name: nil, **attrs)
        @value = value
        @disabled = disabled
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
          attrs[:role] = attrs.fetch(:role, "tab")
          attrs[:class] = trigger_classes
          attrs[:data] = trigger_data(attrs[:data])

          next unless @disabled

          attrs[:disabled] = true
          attrs[:aria] = attrs.fetch(:aria, {}).dup.merge(disabled: "true")
        end
      end

      def trigger_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "tabs-trigger"
          data[:ui_tabs_target] = append_token(data[:ui_tabs_target], "trigger")
          data[:ui_tabs_value] = @value.to_s
          data[:action] = append_token(data[:action], "click->ui-tabs#select keydown->ui-tabs#navigate")
          data[:disabled] = "" if @disabled
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def trigger_classes
        class_names(base_classes, @class_name)
      end

      def base_classes
        "inline-flex flex-1 items-center justify-center gap-1.5 whitespace-nowrap rounded-md border border-transparent px-2 py-1 text-sm font-medium text-muted-foreground transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow-sm [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0"
      end
    end
  end
end
