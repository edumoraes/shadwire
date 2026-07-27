# frozen_string_literal: true

module Ui
  module ContextMenuHelper
    def ui_context_menu(**options, &block)
      render(Ui::ContextMenuComponent.new(**options), &block)
    end

    def ui_context_menu_trigger(**options, &block)
      render(Ui::ContextMenu::TriggerComponent.new(**options), &block)
    end

    def ui_context_menu_content(**options, &block)
      render(Ui::ContextMenu::ContentComponent.new(**options), &block)
    end

    def ui_context_menu_item(**options, &block)
      render(Ui::ContextMenu::ItemComponent.new(**options), &block)
    end

    def ui_context_menu_label(**options, &block)
      render(Ui::ContextMenu::LabelComponent.new(**options), &block)
    end

    def ui_context_menu_separator(**options)
      render(Ui::ContextMenu::SeparatorComponent.new(**options))
    end

    def ui_context_menu_group(**options, &block)
      render(Ui::ContextMenu::GroupComponent.new(**options), &block)
    end

    def ui_context_menu_shortcut(**options, &block)
      render(Ui::ContextMenu::ShortcutComponent.new(**options), &block)
    end
  end
end
