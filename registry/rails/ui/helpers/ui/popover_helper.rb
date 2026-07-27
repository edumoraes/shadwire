# frozen_string_literal: true

module Ui
  module PopoverHelper
    def ui_popover(**options, &block)
      render(Ui::PopoverComponent.new(**options), &block)
    end

    def ui_popover_trigger(**options, &block)
      render(Ui::Popover::TriggerComponent.new(**options), &block)
    end

    def ui_popover_content(**options, &block)
      render(Ui::Popover::ContentComponent.new(**options), &block)
    end
  end
end
