# frozen_string_literal: true

module Ui
  module Blocks
    module Sidebar01
      # The header search field: a SidebarInput with an inset search icon,
      # wrapped in a labelled search form.
      class SearchFormComponent < UiComponent
        include UiHelper

        def initialize(**attrs)
          @attrs = attrs
        end
      end
    end
  end
end
