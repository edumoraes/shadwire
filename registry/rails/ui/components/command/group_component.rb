# frozen_string_literal: true

module Ui
  module Command
    # A labelled group of command items. The controller hides the whole group
    # when the filter empties it.
    class GroupComponent < UiComponent
      def initialize(heading: nil, class_name: nil, **attrs)
        @heading = heading
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(**group_attrs) do
          safe_join([ heading_tag, content ].compact)
        end
      end

      private

      def group_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "group")
          attrs[:class] = class_names("overflow-hidden p-1 text-foreground", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "command-group"
            data[:ui_command_target] = append_token(data[:ui_command_target], "group")
          end
        end
      end

      def heading_tag
        return unless @heading.present?

        tag.div(@heading, class: "px-2 py-1.5 text-xs font-medium text-muted-foreground", data: { slot: "command-group-heading" })
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
