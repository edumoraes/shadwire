# frozen_string_literal: true

module Ui
  # A command palette: a filterable list of actions. The ui-command controller
  # filters items as you type and moves the active option with the arrow keys.
  # Compose `Ui::Command::InputComponent`, `ListComponent`, `GroupComponent`,
  # `ItemComponent` and `EmptyComponent`.
  class CommandComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **command_attrs)
    end

    private

    def command_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(base_classes, @class_name)
        attrs[:data] = command_data(attrs[:data])
      end
    end

    def command_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "command"
        data[:controller] = append_token(data[:controller], "ui-command")
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end

    def base_classes
      "flex h-full w-full flex-col overflow-hidden rounded-md border bg-popover text-popover-foreground"
    end
  end
end
