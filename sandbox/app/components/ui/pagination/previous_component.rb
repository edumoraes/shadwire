# frozen_string_literal: true

module Ui
  module Pagination
    class PreviousComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(
          Ui::Pagination::LinkComponent.new(
            size: :default,
            class_name: class_names("gap-1 px-2.5 sm:pl-2.5", @class_name),
            **previous_attrs
          )
        ) do
          safe_join([ render(Ui::IconComponent.new("chevron-left")), label_html ])
        end
      end

      private

      def previous_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:aria] = { label: "Ir para a página anterior" }.merge(attrs.fetch(:aria, {}))
        end
      end

      def label_html
        tag.span(content.presence || "Anterior", class: "hidden sm:block")
      end
    end
  end
end
