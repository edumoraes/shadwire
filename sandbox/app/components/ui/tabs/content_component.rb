# frozen_string_literal: true

module Ui
  module Tabs
    # Panels render hidden; the ui-tabs controller reveals the active one.
    class ContentComponent < UiComponent
      def initialize(value:, class_name: nil, **attrs)
        @value = value
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **content_attrs)
      end

      private

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "tabpanel")
          attrs[:tabindex] = attrs.fetch(:tabindex, "0")
          attrs[:hidden] = attrs.fetch(:hidden, true)
          attrs[:class] = class_names("flex-1 outline-none", @class_name)
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "tabs-content"
          data[:ui_tabs_target] = append_token(data[:ui_tabs_target], "panel")
          data[:ui_tabs_value] = @value.to_s
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
