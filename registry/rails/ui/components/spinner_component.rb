# frozen_string_literal: true

module Ui
  # A spinning loading indicator built on the Lucide `loader-circle` icon.
  # Exposes `role="status"` with an accessible label so a standalone spinner
  # announces; pass `label: nil` to make it decorative next to visible text.
  class SpinnerComponent < UiComponent
    def initialize(label: "Carregando", class_name: nil, **attrs)
      @label = label
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      helpers.lucide_icon("loader-circle", **spinner_attrs)
    end

    private

    def spinner_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("size-4 animate-spin", @class_name)
        attrs[:role] = attrs.fetch(:role, "status")
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "spinner")
        attrs[:"aria-label"] = @label if @label.present?
        attrs[:"aria-hidden"] = "true" if @label.blank?
      end
    end
  end
end
