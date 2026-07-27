# frozen_string_literal: true

module Ui
  module LabelHelper
    def ui_label(**options, &block)
      render(Ui::LabelComponent.new(**options), &block)
    end
  end
end
