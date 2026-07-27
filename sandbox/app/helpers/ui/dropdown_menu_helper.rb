# frozen_string_literal: true

module Ui
  module DropdownMenuHelper
    def ui_dropdown_menu(**options, &block)
      render(Ui::DropdownMenuComponent.new(**options), &block)
    end

    def ui_dropdown_menu_trigger(**options, &block)
      render(Ui::DropdownMenu::TriggerComponent.new(**options), &block)
    end

    def ui_dropdown_menu_content(**options, &block)
      render(Ui::DropdownMenu::ContentComponent.new(**options), &block)
    end

    def ui_dropdown_menu_item(**options, &block)
      render(Ui::DropdownMenu::ItemComponent.new(**options), &block)
    end

    def ui_dropdown_menu_label(**options, &block)
      render(Ui::DropdownMenu::LabelComponent.new(**options), &block)
    end

    def ui_dropdown_menu_separator(**options)
      render(Ui::DropdownMenu::SeparatorComponent.new(**options))
    end

    def ui_dropdown_menu_group(**options, &block)
      render(Ui::DropdownMenu::GroupComponent.new(**options), &block)
    end

    def ui_dropdown_menu_shortcut(**options, &block)
      render(Ui::DropdownMenu::ShortcutComponent.new(**options), &block)
    end
  end
end
