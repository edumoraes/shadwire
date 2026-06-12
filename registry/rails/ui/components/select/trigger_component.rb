# frozen_string_literal: true

module Ui
  module Select
    # The combobox button. Focus stays here while the listbox is open.
    class TriggerComponent < UiComponent
      SIZES = {
        default: "h-9",
        sm: "h-8"
      }.freeze

      def initialize(size: :default, disabled: false, class_name: nil, **attrs)
        @size = size
        @disabled = disabled
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.button(**trigger_attrs) do
          safe_join([ content, render(Ui::IconComponent.new("chevron-down", class: "size-4 opacity-50")) ])
        end
      end

      private

      def trigger_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = attrs.fetch(:type, "button")
          attrs[:role] = attrs.fetch(:role, "combobox")
          attrs[:class] = trigger_classes
          attrs[:aria] = { haspopup: "listbox", expanded: "false" }.merge(attrs.fetch(:aria, {}))
          attrs[:data] = trigger_data(attrs[:data])

          next unless @disabled

          attrs[:disabled] = true
        end
      end

      def trigger_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "select-trigger"
          data[:ui_select_target] = append_token(data[:ui_select_target], "trigger")
          data[:action] = append_token(data[:action], "click->ui-select#toggle keydown->ui-select#keydown")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def trigger_classes
        class_names(base_classes, fetch_variant(SIZES, @size, fallback: :default), @class_name)
      end

      def base_classes
        "flex w-fit items-center justify-between gap-2 whitespace-nowrap rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-xs outline-none transition-[color,box-shadow] focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 data-[placeholder]:text-muted-foreground aria-invalid:border-destructive dark:bg-input/30 [&_svg]:pointer-events-none [&_svg]:shrink-0"
      end
    end
  end
end
