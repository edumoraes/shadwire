# frozen_string_literal: true

module Ui
  module Blocks
    module Sidebar01
      # The full sidebar-01 dashboard page: a SidebarProvider wrapping the
      # AppSidebar and a SidebarInset whose header carries the trigger, a
      # separator and a breadcrumb, followed by placeholder content. This is the
      # entry point you render in a view.
      class PageComponent < UiComponent
        include UiHelper

        def initialize(**attrs)
          @attrs = attrs
        end
      end
    end
  end
end
