# frozen_string_literal: true

module Ui
  module ButtonGroupHelper
    def ui_button_group(**options, &block)
      render(Ui::ButtonGroupComponent.new(**options), &block)
    end

    def ui_button_group_text(**options, &block)
      render(Ui::ButtonGroup::TextComponent.new(**options), &block)
    end

    def ui_button_group_separator(**options)
      render(Ui::ButtonGroup::SeparatorComponent.new(**options))
    end
  end
end
