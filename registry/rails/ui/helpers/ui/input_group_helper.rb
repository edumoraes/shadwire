# frozen_string_literal: true

module Ui
  module InputGroupHelper
    def ui_input_group(**options, &block)
      render(Ui::InputGroupComponent.new(**options), &block)
    end

    def ui_input_group_addon(**options, &block)
      render(Ui::InputGroup::AddonComponent.new(**options), &block)
    end

    def ui_input_group_text(**options, &block)
      render(Ui::InputGroup::TextComponent.new(**options), &block)
    end

    def ui_input_group_input(**options)
      render(Ui::InputGroup::InputComponent.new(**options))
    end

    def ui_input_group_textarea(**options, &block)
      render(Ui::InputGroup::TextareaComponent.new(**options), &block)
    end

    def ui_input_group_button(**options, &block)
      render(Ui::InputGroup::ButtonComponent.new(**options), &block)
    end
  end
end
