# frozen_string_literal: true

module Ui
  module RadioGroupHelper
    def ui_radio_group(**options, &block)
      render(Ui::RadioGroupComponent.new(**options), &block)
    end

    def ui_radio_group_item(**options)
      render(Ui::RadioGroup::ItemComponent.new(**options))
    end
  end
end
