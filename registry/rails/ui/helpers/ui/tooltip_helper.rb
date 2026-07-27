# frozen_string_literal: true

module Ui
  module TooltipHelper
    def ui_tooltip(**options, &block)
      render(Ui::TooltipComponent.new(**options), &block)
    end

    def ui_tooltip_trigger(**options, &block)
      render(Ui::Tooltip::TriggerComponent.new(**options), &block)
    end

    def ui_tooltip_content(**options, &block)
      render(Ui::Tooltip::ContentComponent.new(**options), &block)
    end
  end
end
