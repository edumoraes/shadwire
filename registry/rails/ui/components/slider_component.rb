# frozen_string_literal: true

module Ui
  # A single-thumb slider following the WAI-ARIA slider pattern. The value is
  # mirrored into a hidden input (`name:`) for form submission. Drag the thumb
  # or use arrow/Home/End keys.
  class SliderComponent < UiComponent
    def initialize(min: 0, max: 100, step: 1, value: 0, name: nil, label: nil, disabled: false, class_name: nil, **attrs)
      @min = min
      @max = max
      @step = step
      @value = value
      @name = name
      @label = label
      @disabled = disabled
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(**slider_attrs) do
        safe_join([ track, thumb, hidden_input ].compact)
      end
    end

    private

    def slider_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("relative flex w-full touch-none items-center select-none data-[disabled]:opacity-50", @class_name)
        attrs[:data] = slider_data(attrs[:data])
        attrs[:data][:disabled] = "" if @disabled
      end
    end

    def slider_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "slider"
        data[:controller] = append_token(data[:controller], "ui-slider")
        data[:ui_slider_min_value] = @min
        data[:ui_slider_max_value] = @max
        data[:ui_slider_step_value] = @step
        data[:ui_slider_value_value] = @value
      end
    end

    def track
      tag.div(
        class: "bg-muted relative h-1.5 w-full grow overflow-hidden rounded-full",
        data: { slot: "slider-track", ui_slider_target: "track", action: "pointerdown->ui-slider#trackPointerDown" }
      ) do
        tag.div(class: "bg-primary absolute h-full", style: "width: #{percent}%", data: { slot: "slider-range", ui_slider_target: "range" })
      end
    end

    def thumb
      tag.span(
        role: "slider",
        tabindex: @disabled ? nil : "0",
        style: "left: #{percent}%",
        class: "border-primary bg-background ring-ring/50 absolute block size-4 shrink-0 -translate-x-1/2 rounded-full border shadow-sm transition-[color,box-shadow] hover:ring-4 focus-visible:ring-4 focus-visible:outline-none disabled:pointer-events-none",
        aria: aria_attrs,
        data: { slot: "slider-thumb", ui_slider_target: "thumb", action: "keydown->ui-slider#keydown pointerdown->ui-slider#thumbPointerDown" }
      )
    end

    def aria_attrs
      base = { valuemin: @min, valuemax: @max, valuenow: @value, orientation: "horizontal", disabled: (@disabled ? "true" : nil) }.compact
      base[:label] = @label if @label.present?
      base
    end

    def hidden_input
      return unless @name.present?

      tag.input(type: "hidden", name: @name, value: @value, data: { ui_slider_target: "input" })
    end

    def percent
      span = (@max - @min).to_f
      return 0 if span.zero?

      ((@value - @min) / span * 100).clamp(0, 100)
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
