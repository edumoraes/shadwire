# frozen_string_literal: true

module Ui
  module Drawer
    class TitleComponent < UiComponent
      def initialize(tag_name: :h2, class_name: nil, **attrs)
        @tag_name = tag_name
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag_name, content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("text-lg font-semibold text-foreground", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "drawer-title")
        end)
      end
    end
  end
end
