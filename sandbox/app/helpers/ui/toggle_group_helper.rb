# frozen_string_literal: true

module Ui
  module ToggleGroupHelper
    def ui_toggle_group(**options, &block)
      render(Ui::ToggleGroupComponent.new(**options), &block)
    end

    def ui_toggle_group_item(**options, &block)
      render(Ui::ToggleGroup::ItemComponent.new(**options), &block)
    end
  end
end
