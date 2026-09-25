# frozen_string_literal: true

module Ui
  module ButtonGroup
    # A vertical divider between segments of a `Ui::ButtonGroupComponent`.
    class SeparatorComponent < UiComponent
      def initialize(orientation: :vertical, class_name: nil, **attrs)
        @orientation = orientation
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(Ui::SeparatorComponent.new(
          orientation: @orientation,
          class: class_names("bg-input relative m-0! self-stretch data-[orientation=vertical]:h-auto", @class_name),
          **html_attrs,
          data: html_attrs[:data].to_h.merge(slot: "button-group-separator")
        ))
      end
    end
  end
end
