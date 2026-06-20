# frozen_string_literal: true

module Ui
  module Sidebar
    # The button that toggles the sidebar. A ghost, icon-sized Button wired to
    # the `ui-sidebar` controller. Pass a block to override the default icon.
    class TriggerComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(Ui::ButtonComponent.new(variant: :ghost, size: :icon, class_name: trigger_classes, **trigger_attrs)) do
          safe_join([ trigger_content, tag.span("Toggle Sidebar", class: "sr-only") ])
        end
      end

      private

      def trigger_content
        content.presence || render(Ui::IconComponent.new("panel-left"))
      end

      def trigger_classes
        class_names("size-7", @class_name)
      end

      def trigger_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "sidebar-trigger"
            data[:action] = append_token(data[:action], "click->ui-sidebar#toggle")
          end
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
