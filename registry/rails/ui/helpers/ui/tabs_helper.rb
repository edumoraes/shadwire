# frozen_string_literal: true

module Ui
  module TabsHelper
    def ui_tabs(**options, &block)
      render(Ui::TabsComponent.new(**options), &block)
    end

    def ui_tabs_list(**options, &block)
      render(Ui::Tabs::ListComponent.new(**options), &block)
    end

    def ui_tabs_trigger(**options, &block)
      render(Ui::Tabs::TriggerComponent.new(**options), &block)
    end

    def ui_tabs_content(**options, &block)
      render(Ui::Tabs::ContentComponent.new(**options), &block)
    end
  end
end
