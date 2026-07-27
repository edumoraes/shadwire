# frozen_string_literal: true

module Ui
  module DrawerHelper
    def ui_drawer(**options, &block)
      render(Ui::DrawerComponent.new(**options), &block)
    end

    def ui_drawer_trigger(**options, &block)
      render(Ui::Drawer::TriggerComponent.new(**options), &block)
    end

    def ui_drawer_content(**options, &block)
      render(Ui::Drawer::ContentComponent.new(**options), &block)
    end

    def ui_drawer_header(**options, &block)
      render(Ui::Drawer::HeaderComponent.new(**options), &block)
    end

    def ui_drawer_footer(**options, &block)
      render(Ui::Drawer::FooterComponent.new(**options), &block)
    end

    def ui_drawer_title(**options, &block)
      render(Ui::Drawer::TitleComponent.new(**options), &block)
    end

    def ui_drawer_description(**options, &block)
      render(Ui::Drawer::DescriptionComponent.new(**options), &block)
    end

    def ui_drawer_close(**options, &block)
      render(Ui::Drawer::CloseComponent.new(**options), &block)
    end
  end
end
