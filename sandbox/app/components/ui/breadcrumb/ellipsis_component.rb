# frozen_string_literal: true

module Ui
  module Breadcrumb
    class EllipsisComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.span(**ellipsis_attrs) do
          safe_join([ render(Ui::IconComponent.new("ellipsis")), tag.span("Mais", class: "sr-only") ])
        end
      end

      private

      def ellipsis_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "presentation")
          attrs[:class] = class_names("flex size-9 items-center justify-center", @class_name)
          attrs[:aria] = { hidden: "true" }.merge(attrs.fetch(:aria, {}))
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "breadcrumb-ellipsis")
        end
      end
    end
  end
end
