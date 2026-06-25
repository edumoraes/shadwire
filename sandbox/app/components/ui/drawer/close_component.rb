# frozen_string_literal: true

module Ui
  module Drawer
    # A Button that closes the surrounding drawer.
    class CloseComponent < UiComponent
      def initialize(variant: :outline, size: :default, class_name: nil, **attrs)
        @variant = variant
        @size = size
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(Ui::ButtonComponent.new(variant: @variant, size: @size, class_name: @class_name, **close_attrs)) { content }
      end

      private

      def close_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "drawer-close"
            data[:action] = append_token(data[:action], "click->ui-drawer#close")
          end
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
