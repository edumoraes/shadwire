# frozen_string_literal: true

module Ui
  module Item
    # A horizontal rule between items, built on `Ui::SeparatorComponent`.
    class SeparatorComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(Ui::SeparatorComponent.new(
          orientation: :horizontal,
          class: class_names("my-0", @class_name),
          data: { slot: "item-separator" },
          **html_attrs
        ))
      end
    end
  end
end
