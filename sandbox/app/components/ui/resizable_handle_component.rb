# frozen_string_literal: true

module Ui
  # The draggable divider between two `Ui::ResizablePanelComponent`s. Focusable
  # and adjustable with the arrow keys (`role="separator"`).
  class ResizableHandleComponent < UiComponent
    def initialize(with_handle: false, class_name: nil, **attrs)
      @with_handle = with_handle
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(**handle_attrs) do
        grip if @with_handle
      end
    end

    private

    def handle_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:role] = attrs.fetch(:role, "separator")
        attrs[:tabindex] = attrs.fetch(:tabindex, "0")
        attrs[:class] = class_names(base_classes, @class_name)
        attrs[:data] = handle_data(attrs[:data])
      end
    end

    def handle_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "resizable-handle"
        data[:ui_resizable_target] = append_token(data[:ui_resizable_target], "handle")
        data[:action] = append_token(data[:action], "pointerdown->ui-resizable#start keydown->ui-resizable#keydown")
      end
    end

    def grip
      tag.div(
        class: "z-10 flex h-4 w-3 items-center justify-center rounded-xs border bg-border",
        aria: { hidden: "true" }
      ) { helpers.lucide_icon("grip-vertical", class: "size-2.5") }
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end

    def base_classes
      "relative flex w-px shrink-0 cursor-col-resize items-center justify-center bg-border " \
      "focus-visible:ring-1 focus-visible:ring-ring focus-visible:outline-none " \
      "group-data-[direction=vertical]/resizable:h-px group-data-[direction=vertical]/resizable:w-full " \
      "group-data-[direction=vertical]/resizable:cursor-row-resize"
    end
  end
end
