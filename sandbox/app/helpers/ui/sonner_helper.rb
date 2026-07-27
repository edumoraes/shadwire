# frozen_string_literal: true

module Ui
  module SonnerHelper
    def ui_sonner(**options, &block)
      render(Ui::SonnerComponent.new(**options), &block)
    end
  end
end
