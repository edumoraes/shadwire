# frozen_string_literal: true

module Ui
  module DropdownMenu
    class LabelComponent < UiComponent
      def initialize(inset: false, class_name: nil, **attrs)
        @inset = inset
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **label_attrs)
      end

      private

      def label_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("px-2 py-1.5 text-sm font-medium data-[inset]:pl-8", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "dropdown-menu-label"
            data[:inset] = "" if @inset
          end
        end
      end
    end
  end
end
