# frozen_string_literal: true

module Ui
  module Sidebar
    # An `Ui::SeparatorComponent` inset to the sidebar's padding.
    class SeparatorComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(Ui::SeparatorComponent.new(class_name: separator_classes, **separator_attrs))
      end

      private

      def separator_classes
        class_names("bg-sidebar-border mx-2 w-auto", @class_name)
      end

      def separator_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-separator")
        end
      end
    end
  end
end
