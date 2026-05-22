# frozen_string_literal: true

require "json"

module Ui
  class AccordionComponent < UiComponent
    def initialize(
      multiple: false,
      default_value: nil,
      orientation: :vertical,
      disabled: false,
      loop_focus: true,
      class_name: nil,
      **attrs
    )
      @multiple = multiple
      @default_value = normalize_default_value(default_value)
      @orientation = orientation
      @disabled = disabled
      @loop_focus = loop_focus
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **accordion_attrs)
    end

    private

    def accordion_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:role] = attrs.fetch(:role, "region")
        attrs[:class] = class_names(@class_name)
        attrs[:data] = accordion_data(attrs[:data])
        attrs[:aria] = attrs.fetch(:aria, {}).dup

        next unless @disabled

        attrs[:aria] = attrs[:aria].merge(disabled: "true")
      end
    end

    def accordion_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "accordion"
        data[:controller] = append_token(data[:controller], "ui-accordion")
        data[:orientation] = @orientation.to_s
        data[:ui_accordion_multiple_value] = @multiple
        data[:ui_accordion_default_value_value] = JSON.generate(@default_value)
        data[:ui_accordion_loop_focus_value] = @loop_focus
        data[:ui_accordion_disabled_value] = @disabled
        data[:disabled] = "" if @disabled
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end

    def normalize_default_value(value)
      Array.wrap(value).compact.map(&:to_s)
    end
  end
end
