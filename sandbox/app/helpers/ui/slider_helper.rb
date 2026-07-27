# frozen_string_literal: true

module Ui
  module SliderHelper
    def ui_slider(**options)
      render(Ui::SliderComponent.new(**options))
    end
  end
end
