# frozen_string_literal: true

module Ui
  # One panel within a `Ui::ResizablePanelGroupComponent`. `default_size:` is the
  # initial flex-grow weight (relative to its siblings); the controller adjusts it
  # as handles are dragged.
  class ResizablePanelComponent < UiComponent
    def initialize(default_size: nil, class_name: nil, **attrs)
      @default_size = default_size
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **panel_attrs)
    end

    private

    def panel_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("overflow-hidden", @class_name)
        attrs[:data] = panel_data(attrs[:data])
      end
    end

    def panel_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "resizable-panel"
        data[:ui_resizable_target] = append_token(data[:ui_resizable_target], "panel")
        data[:default_size] = @default_size if @default_size.present?
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
