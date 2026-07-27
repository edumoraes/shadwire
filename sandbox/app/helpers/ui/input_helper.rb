# frozen_string_literal: true

module Ui
  module InputHelper
    def ui_input(**options)
      render(Ui::InputComponent.new(**options))
    end
  end
end
