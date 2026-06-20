# frozen_string_literal: true

module Ui
  module Sidebar
    # The main content area that sits beside the sidebar. As the sidebar's peer
    # sibling it reacts to `data-variant=inset`/`data-state` for the inset look.
    class InsetComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.main(content, **inset_attrs)
      end

      private

      def inset_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = inset_classes
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "sidebar-inset")
        end
      end

      def inset_classes
        class_names(
          "bg-background relative flex w-full flex-1 flex-col",
          "md:peer-data-[variant=inset]:m-2 md:peer-data-[variant=inset]:ml-0 md:peer-data-[variant=inset]:rounded-xl md:peer-data-[variant=inset]:shadow-sm md:peer-data-[variant=inset]:peer-data-[state=collapsed]:ml-2",
          @class_name
        )
      end
    end
  end
end
