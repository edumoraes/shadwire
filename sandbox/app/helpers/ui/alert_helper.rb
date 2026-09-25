# frozen_string_literal: true

module Ui
  module AlertHelper
    def ui_alert(**options, &block)
      render(Ui::AlertComponent.new(**options), &block)
    end

    def ui_alert_title(**options, &block)
      render(Ui::Alert::TitleComponent.new(**options), &block)
    end

    def ui_alert_description(**options, &block)
      render(Ui::Alert::DescriptionComponent.new(**options), &block)
    end
  end
end
