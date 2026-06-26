# frozen_string_literal: true

module Ui
  module Command
    # The search field that filters the command list.
    class InputComponent < UiComponent
      def initialize(placeholder: nil, class_name: nil, **attrs)
        @placeholder = placeholder
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(class: "flex items-center gap-2 border-b px-3", data: { slot: "command-input-wrapper" }) do
          safe_join([ icon, field ])
        end
      end

      private

      def icon
        helpers.lucide_icon("search", class: "size-4 shrink-0 opacity-50", "aria-hidden": "true")
      end

      def field
        tag.input(**field_attrs)
      end

      def field_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = attrs.fetch(:type, "text")
          attrs[:placeholder] = @placeholder if @placeholder.present?
          attrs[:autocomplete] = attrs.fetch(:autocomplete, "off")
          attrs[:role] = attrs.fetch(:role, "combobox")
          attrs[:aria] = { expanded: "true", autocomplete: "list" }.merge(attrs.fetch(:aria, {}))
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = field_data(attrs[:data])
        end
      end

      def field_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "command-input"
          data[:ui_command_target] = append_token(data[:ui_command_target], "input")
          data[:action] = append_token(data[:action], "input->ui-command#filter keydown->ui-command#keydown")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "flex h-10 w-full rounded-md bg-transparent py-3 text-sm outline-none placeholder:text-muted-foreground disabled:cursor-not-allowed disabled:opacity-50"
      end
    end
  end
end
