# frozen_string_literal: true

module Ui
  class TabsComponent < UiComponent
    def initialize(default_value: nil, class_name: nil, **attrs)
      @default_value = default_value
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **tabs_attrs)
    end

    private

    def tabs_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("flex flex-col gap-2", @class_name)
        attrs[:data] = tabs_data(attrs[:data])
      end
    end

    def tabs_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "tabs"
        data[:controller] = append_token(data[:controller], "ui-tabs")
        data[:ui_tabs_default_value_value] = @default_value.to_s if @default_value.present?
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
