# frozen_string_literal: true

module Ui
  module AlertDialogHelper
    def ui_alert_dialog(**options, &block)
      render(Ui::AlertDialogComponent.new(**options), &block)
    end

    def ui_alert_dialog_trigger(**options, &block)
      render(Ui::AlertDialog::TriggerComponent.new(**options), &block)
    end

    def ui_alert_dialog_content(**options, &block)
      render(Ui::AlertDialog::ContentComponent.new(**options), &block)
    end

    def ui_alert_dialog_header(**options, &block)
      render(Ui::AlertDialog::HeaderComponent.new(**options), &block)
    end

    def ui_alert_dialog_footer(**options, &block)
      render(Ui::AlertDialog::FooterComponent.new(**options), &block)
    end

    def ui_alert_dialog_title(**options, &block)
      render(Ui::AlertDialog::TitleComponent.new(**options), &block)
    end

    def ui_alert_dialog_description(**options, &block)
      render(Ui::AlertDialog::DescriptionComponent.new(**options), &block)
    end

    def ui_alert_dialog_action(**options, &block)
      render(Ui::AlertDialog::ActionComponent.new(**options), &block)
    end

    def ui_alert_dialog_cancel(**options, &block)
      render(Ui::AlertDialog::CancelComponent.new(**options), &block)
    end
  end
end
