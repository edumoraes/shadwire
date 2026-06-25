# frozen_string_literal: true

module Ui
  module Command
    class ListComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "listbox")
          attrs[:class] = class_names("max-h-72 overflow-y-auto overflow-x-hidden p-1", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "command-list"
            data[:ui_command_target] = append_token(data[:ui_command_target], "list")
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
