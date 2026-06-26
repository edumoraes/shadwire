# frozen_string_literal: true

module Ui
  # A form field wrapper that lays out a label, control, description and error.
  # `orientation:` is `:vertical` (default), `:horizontal`, or `:responsive`.
  # Pass `invalid: true` to flag validation state (sets `data-invalid`).
  class FieldComponent < UiComponent
    ORIENTATIONS = {
      vertical: "flex-col [&>*]:w-full [&>.sr-only]:w-auto",
      horizontal: "flex-row items-center [&>[data-slot=field-label]]:flex-auto",
      responsive: "flex-col [&>*]:w-full @md/field-group:flex-row @md/field-group:items-center @md/field-group:[&>*]:w-auto @md/field-group:[&>[data-slot=field-label]]:flex-auto"
    }.freeze

    def initialize(orientation: :vertical, invalid: false, class_name: nil, **attrs)
      @orientation = orientation
      @invalid = invalid
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **field_attrs)
    end

    private

    def field_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:role] = attrs.fetch(:role, "group")
        attrs[:class] = class_names(base_classes, fetch_variant(ORIENTATIONS, @orientation, fallback: :vertical), @class_name)
        data = attrs.fetch(:data, {}).dup.merge(slot: "field", orientation: @orientation.to_s)
        data[:invalid] = "true" if @invalid
        attrs[:data] = data
      end
    end

    def base_classes
      "group/field flex w-full gap-3 data-[invalid=true]:text-destructive"
    end
  end
end
