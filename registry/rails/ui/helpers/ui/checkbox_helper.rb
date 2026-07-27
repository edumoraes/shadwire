# frozen_string_literal: true

module Ui
  module CheckboxHelper
    def ui_checkbox(**options)
      render(Ui::CheckboxComponent.new(**options))
    end
  end
end
