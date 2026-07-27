# frozen_string_literal: true

module Ui
  module ChartHelper
    def ui_chart(**options)
      render(Ui::ChartComponent.new(**options))
    end
  end
end
