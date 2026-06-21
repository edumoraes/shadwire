# frozen_string_literal: true

module Ui
  module Sidebar
    # Hosts the `ui-sidebar` Stimulus controller and exposes the sidebar width
    # CSS variables to its subtree. Wrap a `Ui::SidebarComponent` (the peer) and
    # a `Ui::Sidebar::InsetComponent` (the content) inside it. `default_open:`
    # seeds the controller; the controller then reconciles with the persisted
    # cookie on connect.
    class ProviderComponent < UiComponent
      STYLE = "--sidebar-width: 16rem; --sidebar-width-icon: 3rem; --sidebar-width-mobile: 18rem;"

      def initialize(default_open: true, cookie_name: "sidebar_state", class_name: nil, **attrs)
        @default_open = default_open
        @cookie_name = cookie_name
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **provider_attrs)
      end

      private

      def provider_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:style] = [ STYLE, attrs[:style] ].compact_blank.join(" ")
          attrs[:class] = class_names("group/sidebar-wrapper flex min-h-svh w-full", @class_name)
          attrs[:data] = provider_data(attrs[:data])
        end
      end

      def provider_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "sidebar-wrapper"
          data[:controller] = append_token(data[:controller], "ui-sidebar")
          data[:ui_sidebar_open_value] = @default_open
          data[:ui_sidebar_cookie_name_value] = @cookie_name
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
