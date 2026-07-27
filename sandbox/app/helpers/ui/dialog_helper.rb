# frozen_string_literal: true

module Ui
  module DialogHelper
    def ui_dialog(**options, &block)
      render(Ui::DialogComponent.new(**options), &block)
    end

    def ui_dialog_trigger(**options, &block)
      render(Ui::Dialog::TriggerComponent.new(**options), &block)
    end

    def ui_dialog_content(**options, &block)
      render(Ui::Dialog::ContentComponent.new(**options), &block)
    end

    def ui_dialog_header(**options, &block)
      render(Ui::Dialog::HeaderComponent.new(**options), &block)
    end

    def ui_dialog_footer(**options, &block)
      render(Ui::Dialog::FooterComponent.new(**options), &block)
    end

    def ui_dialog_title(**options, &block)
      render(Ui::Dialog::TitleComponent.new(**options), &block)
    end

    def ui_dialog_description(**options, &block)
      render(Ui::Dialog::DescriptionComponent.new(**options), &block)
    end

    def ui_dialog_close(**options, &block)
      render(Ui::Dialog::CloseComponent.new(**options), &block)
    end
  end
end
