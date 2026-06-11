# frozen_string_literal: true

module Ui
  module Breadcrumb
    class SeparatorComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.li(**separator_attrs) do
          content.presence || render(Ui::IconComponent.new("chevron-right"))
        end
      end

      private

      def separator_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "presentation")
          attrs[:class] = class_names("[&>svg]:size-3.5", @class_name)
          attrs[:aria] = { hidden: "true" }.merge(attrs.fetch(:aria, {}))
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "breadcrumb-separator")
        end
      end
    end
  end
end
