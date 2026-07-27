# frozen_string_literal: true

module Ui
  module CollapsibleHelper
    def ui_collapsible(**options, &block)
      render(Ui::CollapsibleComponent.new(**options), &block)
    end

    def ui_collapsible_trigger(**options, &block)
      render(Ui::Collapsible::TriggerComponent.new(**options), &block)
    end

    def ui_collapsible_content(**options, &block)
      render(Ui::Collapsible::ContentComponent.new(**options), &block)
    end
  end
end
