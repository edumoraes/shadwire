# frozen_string_literal: true

module Ui
  module SheetHelper
    def ui_sheet(**options, &block)
      render(Ui::SheetComponent.new(**options), &block)
    end

    def ui_sheet_trigger(**options, &block)
      render(Ui::Sheet::TriggerComponent.new(**options), &block)
    end

    def ui_sheet_content(**options, &block)
      render(Ui::Sheet::ContentComponent.new(**options), &block)
    end

    def ui_sheet_header(**options, &block)
      render(Ui::Sheet::HeaderComponent.new(**options), &block)
    end

    def ui_sheet_footer(**options, &block)
      render(Ui::Sheet::FooterComponent.new(**options), &block)
    end

    def ui_sheet_title(**options, &block)
      render(Ui::Sheet::TitleComponent.new(**options), &block)
    end

    def ui_sheet_description(**options, &block)
      render(Ui::Sheet::DescriptionComponent.new(**options), &block)
    end

    def ui_sheet_close(**options, &block)
      render(Ui::Sheet::CloseComponent.new(**options), &block)
    end
  end
end
