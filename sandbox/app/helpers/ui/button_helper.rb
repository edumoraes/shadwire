# frozen_string_literal: true

module Ui
  module ButtonHelper
    def ui_button(**options, &block)
      render(Ui::ButtonComponent.new(**options), &block)
    end
  end
end
