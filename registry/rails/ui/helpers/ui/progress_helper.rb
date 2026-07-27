# frozen_string_literal: true

module Ui
  module ProgressHelper
    def ui_progress(**options)
      render(Ui::ProgressComponent.new(**options))
    end
  end
end
