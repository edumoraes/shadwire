# frozen_string_literal: true

module Ui
  module CardHelper
    def ui_card(**options, &block)
      render(Ui::CardComponent.new(**options), &block)
    end

    def ui_card_header(**options, &block)
      render(Ui::Card::HeaderComponent.new(**options), &block)
    end

    def ui_card_title(**options, &block)
      render(Ui::Card::TitleComponent.new(**options), &block)
    end

    def ui_card_description(**options, &block)
      render(Ui::Card::DescriptionComponent.new(**options), &block)
    end

    def ui_card_content(**options, &block)
      render(Ui::Card::ContentComponent.new(**options), &block)
    end

    def ui_card_footer(**options, &block)
      render(Ui::Card::FooterComponent.new(**options), &block)
    end
  end
end
