# frozen_string_literal: true

module Ui
  module Command
    # The "no results" message; the controller shows it when the filter empties
    # the list.
    class EmptyComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:hidden] = attrs.fetch(:hidden, true)
          attrs[:class] = class_names("py-6 text-center text-sm", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "command-empty"
            data[:ui_command_target] = append_token(data[:ui_command_target], "empty")
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
