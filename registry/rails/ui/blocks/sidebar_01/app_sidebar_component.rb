# frozen_string_literal: true

module Ui
  module Blocks
    module Sidebar01
      # The sidebar for the sidebar-01 block: a documentation-style nav with a
      # version switcher and search in the header, four static groups of links,
      # and a rail. Sample data mirrors the shadcn block.
      class AppSidebarComponent < UiComponent
        include UiHelper

        VERSIONS = [ "1.0.1", "1.1.0-alpha", "2.0.0-beta1" ].freeze

        NAV_MAIN = [
          {
            title: "Getting Started",
            items: [
              { title: "Installation", url: "#" },
              { title: "Project Structure", url: "#" }
            ]
          },
          {
            title: "Building Your Application",
            items: [
              { title: "Routing", url: "#" },
              { title: "Data Fetching", url: "#", active: true },
              { title: "Rendering", url: "#" },
              { title: "Caching", url: "#" }
            ]
          },
          {
            title: "API Reference",
            items: [
              { title: "Components", url: "#" },
              { title: "File Conventions", url: "#" },
              { title: "Functions", url: "#" }
            ]
          },
          {
            title: "Architecture",
            items: [
              { title: "Accessibility", url: "#" },
              { title: "Fast Refresh", url: "#" }
            ]
          }
        ].freeze

        def initialize(class_name: nil, **attrs)
          @attrs = attrs
          @class_name = extract_class_name(@attrs, class_name)
        end

        def versions
          VERSIONS
        end

        def default_version
          VERSIONS.first
        end

        def nav_main
          NAV_MAIN
        end

        def sidebar_attrs
          html_attrs.merge(class: @class_name.presence)
        end
      end
    end
  end
end
