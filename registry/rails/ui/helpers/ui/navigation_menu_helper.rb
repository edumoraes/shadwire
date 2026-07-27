# frozen_string_literal: true

module Ui
  module NavigationMenuHelper
    def ui_navigation_menu(**options, &block)
      render(Ui::NavigationMenuComponent.new(**options), &block)
    end

    def ui_navigation_menu_list(**options, &block)
      render(Ui::NavigationMenu::ListComponent.new(**options), &block)
    end

    def ui_navigation_menu_item(**options, &block)
      render(Ui::NavigationMenu::ItemComponent.new(**options), &block)
    end

    def ui_navigation_menu_trigger(**options, &block)
      render(Ui::NavigationMenu::TriggerComponent.new(**options), &block)
    end

    def ui_navigation_menu_content(**options, &block)
      render(Ui::NavigationMenu::ContentComponent.new(**options), &block)
    end

    def ui_navigation_menu_link(**options, &block)
      render(Ui::NavigationMenu::LinkComponent.new(**options), &block)
    end
  end
end
