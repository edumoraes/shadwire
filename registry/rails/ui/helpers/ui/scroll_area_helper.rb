# frozen_string_literal: true

module Ui
  module ScrollAreaHelper
    def ui_scroll_area(**options, &block)
      render(Ui::ScrollAreaComponent.new(**options), &block)
    end

    def ui_scroll_bar(**options, &block)
      render(Ui::ScrollArea::ScrollbarComponent.new(**options), &block)
    end
  end
end
