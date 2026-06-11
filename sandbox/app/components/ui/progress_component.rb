# frozen_string_literal: true

module Ui
  # Server-rendered progress bar: the value is clamped in Ruby and exposed
  # through the progressbar ARIA contract. Label it with `aria: { label: }`
  # or `aria: { labelledby: }`.
  class ProgressComponent < UiComponent
    def initialize(value: 0, max: 100, class_name: nil, **attrs)
      @max = max.to_f.positive? ? max.to_f : 100.0
      @value = value.to_f.clamp(0.0, @max)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(**progress_attrs) do
        tag.div(**indicator_attrs)
      end
    end

    private

    def progress_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:role] = "progressbar"
        attrs[:class] = progress_classes
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "progress")
        attrs[:aria] = attrs.fetch(:aria, {}).dup.merge(
          valuemin: format_number(0),
          valuemax: format_number(@max),
          valuenow: format_number(@value)
        )
      end
    end

    def indicator_attrs
      {
        class: "size-full flex-1 bg-primary transition-all",
        style: "transform: translateX(-#{format_number(100 - percent)}%)",
        data: { slot: "progress-indicator" }
      }
    end

    def progress_classes
      class_names("relative h-2 w-full overflow-hidden rounded-full bg-primary/20", @class_name)
    end

    def percent
      (@value / @max) * 100
    end

    def format_number(number)
      number % 1 == 0 ? number.to_i : number
    end
  end
end
