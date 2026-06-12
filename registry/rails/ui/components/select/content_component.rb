# frozen_string_literal: true

module Ui
  module Select
    # The listbox surface. Hidden until the controller opens it.
    class ContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **content_attrs)
      end

      private

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "listbox")
          attrs[:hidden] = attrs.fetch(:hidden, true)
          attrs[:class] = content_classes
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "select-content"
          data[:ui_select_target] = append_token(data[:ui_select_target], "content")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def content_classes
        class_names(base_classes, @class_name)
      end

      def base_classes
        "absolute top-full left-0 z-50 mt-1 max-h-60 min-w-[8rem] w-full overflow-y-auto rounded-md border bg-popover p-1 text-popover-foreground shadow-md data-[state=open]:animate-popover-in"
      end
    end
  end
end
