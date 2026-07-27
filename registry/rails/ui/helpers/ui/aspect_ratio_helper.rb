# frozen_string_literal: true

module Ui
  module AspectRatioHelper
    def ui_aspect_ratio(**options, &block)
      render(Ui::AspectRatioComponent.new(**options), &block)
    end
  end
end
