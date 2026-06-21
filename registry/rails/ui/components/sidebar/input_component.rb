# frozen_string_literal: true

module Ui
  module Sidebar
    # An `Ui::InputComponent` tuned for the sidebar (flat, h-8, full width).
    class InputComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(Ui::InputComponent.new(class_name: input_classes, **input_attrs))
      end

      private

      def input_classes
        class_names("bg-background h-8 w-full shadow-none", @class_name)
      end

      def input_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "sidebar-input")
        end
      end
    end
  end
end
