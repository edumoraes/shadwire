# frozen_string_literal: true

module Ui
  module KbdHelper
    def ui_kbd(**options, &block)
      render(Ui::KbdComponent.new(**options), &block)
    end

    def ui_kbd_group(**options, &block)
      render(Ui::Kbd::GroupComponent.new(**options), &block)
    end
  end
end
