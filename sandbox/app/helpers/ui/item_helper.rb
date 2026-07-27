# frozen_string_literal: true

module Ui
  module ItemHelper
    def ui_item(**options, &block)
      render(Ui::ItemComponent.new(**options), &block)
    end

    def ui_item_group(**options, &block)
      render(Ui::Item::GroupComponent.new(**options), &block)
    end

    def ui_item_media(**options, &block)
      render(Ui::Item::MediaComponent.new(**options), &block)
    end

    def ui_item_content(**options, &block)
      render(Ui::Item::ContentComponent.new(**options), &block)
    end

    def ui_item_title(**options, &block)
      render(Ui::Item::TitleComponent.new(**options), &block)
    end

    def ui_item_description(**options, &block)
      render(Ui::Item::DescriptionComponent.new(**options), &block)
    end

    def ui_item_actions(**options, &block)
      render(Ui::Item::ActionsComponent.new(**options), &block)
    end

    def ui_item_header(**options, &block)
      render(Ui::Item::HeaderComponent.new(**options), &block)
    end

    def ui_item_footer(**options, &block)
      render(Ui::Item::FooterComponent.new(**options), &block)
    end

    def ui_item_separator(**options)
      render(Ui::Item::SeparatorComponent.new(**options))
    end
  end
end
