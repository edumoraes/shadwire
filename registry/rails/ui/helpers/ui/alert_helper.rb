# frozen_string_literal: true

module Ui
  module AlertHelper
    def ui_alert(**options, &block)
      render(Ui::AlertComponent.new(**options), &block)
    end
  end
end
