# frozen_string_literal: true

module Ui
  module Sidebar
    # The heading of a sidebar group. Fades out when collapsed to icons.
    class GroupLabelComponent < UiComponent
      def initialize(tag: :div, class_name: nil, **attrs)
        @tag = tag
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag, content, **group_label_attrs)
      end

      private

      def group_label_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-group-label")
        end
      end

      def base_classes
        "text-sidebar-foreground/70 ring-sidebar-ring flex h-8 shrink-0 items-center rounded-md px-2 text-xs font-medium outline-hidden transition-[margin,opacity] duration-200 ease-linear focus-visible:ring-2 [&>svg]:size-4 [&>svg]:shrink-0 group-data-[collapsible=icon]:-mt-8 group-data-[collapsible=icon]:opacity-0"
      end
    end
  end
end
