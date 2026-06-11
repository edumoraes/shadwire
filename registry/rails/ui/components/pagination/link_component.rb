# frozen_string_literal: true

module Ui
  module Pagination
    # A page link with button styling: outline when active, ghost otherwise.
    class LinkComponent < UiComponent
      def initialize(active: false, size: :icon, class_name: nil, **attrs)
        @active = active
        @size = size
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(
          Ui::ButtonComponent.new(
            tag: :a,
            variant: @active ? :outline : :ghost,
            size: @size,
            class_name: @class_name,
            **link_attrs
          )
        ) { content }
      end

      private

      def link_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "pagination-link")

          next unless @active

          attrs[:aria] = attrs.fetch(:aria, {}).dup.merge(current: "page")
          attrs[:data][:active] = ""
        end
      end
    end
  end
end
