# frozen_string_literal: true

module Ui
  module Pagination
    class NextComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(
          Ui::Pagination::LinkComponent.new(
            size: :default,
            class_name: class_names("gap-1 px-2.5 sm:pr-2.5", @class_name),
            **next_attrs
          )
        ) do
          safe_join([ label_html, render(Ui::IconComponent.new("chevron-right")) ])
        end
      end

      private

      def next_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:aria] = { label: "Ir para a próxima página" }.merge(attrs.fetch(:aria, {}))
        end
      end

      def label_html
        tag.span(content.presence || "Próxima", class: "hidden sm:block")
      end
    end
  end
end
