# frozen_string_literal: true

module Ui
  module Field
    # A validation message for a field. Pass text as a block, or an array of
    # messages via `errors:` (rendered as a list). Announced with `role="alert"`.
    class ErrorComponent < UiComponent
      def initialize(errors: nil, class_name: nil, **attrs)
        @errors = Array(errors).compact_blank
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def render?
        content.present? || @errors.any?
      end

      def call
        tag.div(body, **error_attrs)
      end

      private

      def body
        return content if content.present?
        return @errors.first if @errors.one?

        tag.ul(class: "ml-4 flex list-disc flex-col gap-1") do
          safe_join(@errors.map { |message| tag.li(message) })
        end
      end

      def error_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "alert")
          attrs[:class] = class_names("text-destructive text-sm font-normal", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "field-error")
        end
      end
    end
  end
end
