# frozen_string_literal: true

module Ui
  module Sidebar
    # An action button anchored to the top-right of a sidebar group.
    class GroupActionComponent < UiComponent
      def initialize(tag: :button, class_name: nil, **attrs)
        @tag = tag
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag, content, **group_action_attrs)
      end

      private

      def group_action_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = "button" if @tag.to_sym == :button && attrs[:type].blank?
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-group-action")
        end
      end

      def base_classes
        "text-sidebar-foreground ring-sidebar-ring hover:bg-sidebar-accent hover:text-sidebar-accent-foreground absolute top-3.5 right-3 flex aspect-square w-5 items-center justify-center rounded-md p-0 outline-hidden transition-transform focus-visible:ring-2 [&>svg]:size-4 [&>svg]:shrink-0 after:absolute after:-inset-2 md:after:hidden group-data-[collapsible=icon]:hidden"
      end
    end
  end
end
