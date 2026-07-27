# frozen_string_literal: true

module Ui
  module HoverCardHelper
    def ui_hover_card(**options, &block)
      render(Ui::HoverCardComponent.new(**options), &block)
    end

    def ui_hover_card_trigger(**options, &block)
      render(Ui::HoverCard::TriggerComponent.new(**options), &block)
    end

    def ui_hover_card_content(**options, &block)
      render(Ui::HoverCard::ContentComponent.new(**options), &block)
    end
  end
end
