# frozen_string_literal: true

module Ui
  module SelectHelper
    def ui_select(**options, &block)
      render(Ui::SelectComponent.new(**options), &block)
    end

    def ui_select_trigger(**options, &block)
      render(Ui::Select::TriggerComponent.new(**options), &block)
    end

    def ui_select_value(**options, &block)
      render(Ui::Select::ValueComponent.new(**options), &block)
    end

    def ui_select_content(**options, &block)
      render(Ui::Select::ContentComponent.new(**options), &block)
    end

    def ui_select_item(**options, &block)
      render(Ui::Select::ItemComponent.new(**options), &block)
    end

    def ui_select_group(**options, &block)
      render(Ui::Select::GroupComponent.new(**options), &block)
    end

    def ui_select_label(**options, &block)
      render(Ui::Select::LabelComponent.new(**options), &block)
    end

    def ui_select_separator(**options)
      render(Ui::Select::SeparatorComponent.new(**options))
    end
  end
end
