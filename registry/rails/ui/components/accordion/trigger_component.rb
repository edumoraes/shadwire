# frozen_string_literal: true

module Ui
  module Accordion
    class TriggerComponent < UiComponent
      def initialize(disabled: false, class_name: nil, **attrs)
        @disabled = disabled
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.button(**trigger_attrs) do
          safe_join([ content, render(Ui::IconComponent.new("chevron-down", class: icon_classes)) ])
        end
      end

      private

      def trigger_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = attrs.fetch(:type, "button")
          attrs[:class] = trigger_classes
          attrs[:data] = trigger_data(attrs[:data])

          next unless @disabled

          attrs[:disabled] = true
          attrs[:aria] = attrs.fetch(:aria, {}).dup.merge(disabled: "true")
        end
      end

      def trigger_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "accordion-trigger"
          data[:ui_accordion_target] = append_token(data[:ui_accordion_target], "trigger")
          data[:action] = append_token(data[:action], "click->ui-accordion#toggle keydown->ui-accordion#navigate")
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
        "flex flex-1 items-center justify-between py-4 text-left text-sm font-medium transition-all hover:underline disabled:pointer-events-none disabled:opacity-50 [&[data-state=open]>svg]:rotate-180"
      end

      def icon_classes
        "pointer-events-none text-muted-foreground transition-transform duration-200"
      end
    end
  end
end
