# frozen_string_literal: true

module Ui
  module TextareaHelper
    def ui_textarea(**options, &block)
      render(Ui::TextareaComponent.new(**options), &block)
    end
  end
end
