# frozen_string_literal: true

module Ui
  # A native checkbox exposed as a switch: `role="switch"` keeps the toggle
  # semantics while checked state, focus, and forms come from the browser.
  class SwitchComponent < UiComponent
    def initialize(checked: false, disabled: false, class_name: nil, **attrs)
      @checked = checked
      @disabled = disabled
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.input(type: "checkbox", role: "switch", **switch_attrs)
    end

    private

    def switch_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = switch_classes
        attrs[:checked] = true if @checked
        attrs[:disabled] = true if @disabled
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "switch")
      end
    end

    def switch_classes
      class_names(base_classes, @class_name)
    end

    def base_classes
      "shadwire-switch inline-flex h-[1.15rem] w-8 shrink-0 appearance-none items-center rounded-full border border-transparent bg-input shadow-xs transition-colors outline-none checked:bg-primary disabled:cursor-not-allowed disabled:opacity-50 focus-visible:ring-1 focus-visible:ring-ring dark:bg-input/80"
    end
  end
end
