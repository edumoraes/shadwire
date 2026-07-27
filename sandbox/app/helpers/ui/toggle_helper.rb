# frozen_string_literal: true

module Ui
  module ToggleHelper
    def ui_toggle(**options, &block)
      render(Ui::ToggleComponent.new(**options), &block)
    end
  end
end
