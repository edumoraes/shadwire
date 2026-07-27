# frozen_string_literal: true

module Ui
  module AccordionHelper
    def ui_accordion(**options, &block)
      render(Ui::AccordionComponent.new(**options), &block)
    end

    def ui_accordion_item(**options, &block)
      render(Ui::Accordion::ItemComponent.new(**options), &block)
    end

    def ui_accordion_header(**options, &block)
      render(Ui::Accordion::HeaderComponent.new(**options), &block)
    end

    def ui_accordion_trigger(**options, &block)
      render(Ui::Accordion::TriggerComponent.new(**options), &block)
    end

    def ui_accordion_content(**options, &block)
      render(Ui::Accordion::ContentComponent.new(**options), &block)
    end

    def ui_accordion_panel(**options, &block)
      render(Ui::Accordion::PanelComponent.new(**options), &block)
    end
  end
end
