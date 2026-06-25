# frozen_string_literal: true

module Ui
  module Kbd
    # Lays out several `Ui::KbdComponent` keys in a row.
    class GroupComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.kbd(content, **group_attrs)
      end

      private

      def group_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("inline-flex items-center gap-1", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "kbd-group")
        end
      end
    end
  end
end
