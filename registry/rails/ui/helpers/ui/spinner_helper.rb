# frozen_string_literal: true

module Ui
  module SpinnerHelper
    def ui_spinner(**options)
      render(Ui::SpinnerComponent.new(**options))
    end
  end
end
