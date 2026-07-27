# frozen_string_literal: true

module Ui
  module SidebarHelper
    def ui_sidebar_provider(**options, &block)
      render(Ui::Sidebar::ProviderComponent.new(**options), &block)
    end

    def ui_sidebar(**options, &block)
      render(Ui::SidebarComponent.new(**options), &block)
    end

    def ui_sidebar_trigger(**options, &block)
      render(Ui::Sidebar::TriggerComponent.new(**options), &block)
    end

    def ui_sidebar_rail(**options, &block)
      render(Ui::Sidebar::RailComponent.new(**options), &block)
    end

    def ui_sidebar_inset(**options, &block)
      render(Ui::Sidebar::InsetComponent.new(**options), &block)
    end

    def ui_sidebar_input(**options)
      render(Ui::Sidebar::InputComponent.new(**options))
    end

    def ui_sidebar_header(**options, &block)
      render(Ui::Sidebar::HeaderComponent.new(**options), &block)
    end

    def ui_sidebar_footer(**options, &block)
      render(Ui::Sidebar::FooterComponent.new(**options), &block)
    end

    def ui_sidebar_separator(**options)
      render(Ui::Sidebar::SeparatorComponent.new(**options))
    end

    def ui_sidebar_content(**options, &block)
      render(Ui::Sidebar::ContentComponent.new(**options), &block)
    end

    def ui_sidebar_group(**options, &block)
      render(Ui::Sidebar::GroupComponent.new(**options), &block)
    end

    def ui_sidebar_group_label(**options, &block)
      render(Ui::Sidebar::GroupLabelComponent.new(**options), &block)
    end

    def ui_sidebar_group_action(**options, &block)
      render(Ui::Sidebar::GroupActionComponent.new(**options), &block)
    end

    def ui_sidebar_group_content(**options, &block)
      render(Ui::Sidebar::GroupContentComponent.new(**options), &block)
    end

    def ui_sidebar_menu(**options, &block)
      render(Ui::Sidebar::MenuComponent.new(**options), &block)
    end

    def ui_sidebar_menu_item(**options, &block)
      render(Ui::Sidebar::MenuItemComponent.new(**options), &block)
    end

    def ui_sidebar_menu_button(**options, &block)
      render(Ui::Sidebar::MenuButtonComponent.new(**options), &block)
    end

    def ui_sidebar_menu_action(**options, &block)
      render(Ui::Sidebar::MenuActionComponent.new(**options), &block)
    end

    def ui_sidebar_menu_badge(**options, &block)
      render(Ui::Sidebar::MenuBadgeComponent.new(**options), &block)
    end

    def ui_sidebar_menu_skeleton(**options)
      render(Ui::Sidebar::MenuSkeletonComponent.new(**options))
    end

    def ui_sidebar_menu_sub(**options, &block)
      render(Ui::Sidebar::MenuSubComponent.new(**options), &block)
    end

    def ui_sidebar_menu_sub_item(**options, &block)
      render(Ui::Sidebar::MenuSubItemComponent.new(**options), &block)
    end

    def ui_sidebar_menu_sub_button(**options, &block)
      render(Ui::Sidebar::MenuSubButtonComponent.new(**options), &block)
    end
  end
end
