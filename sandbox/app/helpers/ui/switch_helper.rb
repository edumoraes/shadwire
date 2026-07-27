# frozen_string_literal: true

module Ui
  module SwitchHelper
    def ui_switch(**options)
      render(Ui::SwitchComponent.new(**options))
    end
  end
end
