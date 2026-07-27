# frozen_string_literal: true

module Ui
  module SeparatorHelper
    def ui_separator(**options)
      render(Ui::SeparatorComponent.new(**options))
    end
  end
end
