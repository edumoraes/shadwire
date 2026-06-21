# frozen_string_literal: true

module Ui
  module Blocks
    module Sidebar01
      # The header dropdown that switches documentation versions. Built from a
      # SidebarMenuButton wired as a dropdown-menu trigger. The selection is
      # static in this demo (no client state); the active version shows a check.
      class VersionSwitcherComponent < UiComponent
        include UiHelper

        def initialize(versions:, default_version:)
          @versions = versions
          @default_version = default_version
        end

        attr_reader :versions, :default_version
      end
    end
  end
end
