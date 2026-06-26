# frozen_string_literal: true

module Ui
  # A set of related toggles. `type: :single` keeps at most one pressed
  # (radio-like); `:multiple` lets each toggle independently. Compose
  # `Ui::ToggleGroup::ItemComponent`s inside it.
  class ToggleGroupComponent < UiComponent
    def initialize(type: :single, variant: :default, size: :default, orientation: :horizontal, class_name: nil, **attrs)
      @type = type
      @variant = variant
      @size = size
      @orientation = orientation
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **group_attrs)
    end

    private

    def group_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:role] = attrs.fetch(:role, "group")
        attrs[:class] = class_names(base_classes, @class_name)
        attrs[:data] = group_data(attrs[:data])
      end
    end

    def group_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "toggle-group"
        data[:variant] = @variant.to_s
        data[:size] = @size.to_s
        data[:orientation] = @orientation.to_s
        data[:controller] = append_token(data[:controller], "ui-toggle-group")
        data[:ui_toggle_group_type_value] = @type.to_s
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end

    def base_classes
      "group/toggle-group flex w-fit items-center rounded-md data-[variant=outline]:shadow-xs data-[orientation=vertical]:flex-col"
    end
  end
end
