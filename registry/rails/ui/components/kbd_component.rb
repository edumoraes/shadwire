# frozen_string_literal: true

module Ui
  # Renders a keyboard key as a `<kbd>`. Group several inside `Ui::Kbd::GroupComponent`
  # (`ui_kbd_group`) to display a shortcut like ⌘ + K.
  class KbdComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.kbd(content, **kbd_attrs)
    end

    private

    def kbd_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(base_classes, @class_name)
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "kbd")
      end
    end

    def base_classes
      "bg-muted text-muted-foreground pointer-events-none inline-flex h-5 w-fit min-w-5 items-center justify-center gap-1 rounded-sm px-1 font-sans text-[0.7rem] font-medium select-none [&_svg:not([class*='size-'])]:size-3"
    end
  end
end
