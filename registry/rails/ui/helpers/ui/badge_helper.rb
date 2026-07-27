# frozen_string_literal: true

module Ui
  module BadgeHelper
    def ui_badge(**options, &block)
      render(Ui::BadgeComponent.new(**options), &block)
    end
  end
end
