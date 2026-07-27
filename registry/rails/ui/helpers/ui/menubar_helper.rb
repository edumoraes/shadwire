# frozen_string_literal: true

module Ui
  module MenubarHelper
    def ui_menubar(**options, &block)
      render(Ui::MenubarComponent.new(**options), &block)
    end

    def ui_menubar_menu(**options, &block)
      render(Ui::Menubar::MenuComponent.new(**options), &block)
    end

    def ui_menubar_trigger(**options, &block)
      render(Ui::Menubar::TriggerComponent.new(**options), &block)
    end

    def ui_menubar_content(**options, &block)
      render(Ui::Menubar::ContentComponent.new(**options), &block)
    end

    def ui_menubar_item(**options, &block)
      render(Ui::Menubar::ItemComponent.new(**options), &block)
    end

    def ui_menubar_separator(**options)
      render(Ui::Menubar::SeparatorComponent.new(**options))
    end

    def ui_menubar_label(**options, &block)
      render(Ui::Menubar::LabelComponent.new(**options), &block)
    end

    def ui_menubar_shortcut(**options, &block)
      render(Ui::Menubar::ShortcutComponent.new(**options), &block)
    end
  end
end
