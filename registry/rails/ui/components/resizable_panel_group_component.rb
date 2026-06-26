# frozen_string_literal: true

module Ui
  # A group of resizable panels separated by drag handles. `direction:` is
  # `:horizontal` (default) or `:vertical`. Compose `Ui::ResizablePanelComponent`s
  # with `Ui::ResizableHandleComponent`s between them.
  class ResizablePanelGroupComponent < UiComponent
    def initialize(direction: :horizontal, class_name: nil, **attrs)
      @direction = direction
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **group_attrs)
    end

    private

    def group_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(base_classes, @class_name)
        attrs[:data] = group_data(attrs[:data])
      end
    end

    def group_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "resizable-panel-group"
        data[:direction] = @direction.to_s
        data[:controller] = append_token(data[:controller], "ui-resizable")
        data[:ui_resizable_direction_value] = @direction.to_s
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end

    def base_classes
      "group/resizable flex h-full w-full data-[direction=vertical]:flex-col"
    end
  end
end
