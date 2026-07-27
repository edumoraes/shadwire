# frozen_string_literal: true

module Ui
  module FieldHelper
    def ui_field(**options, &block)
      render(Ui::FieldComponent.new(**options), &block)
    end

    def ui_field_set(**options, &block)
      render(Ui::Field::SetComponent.new(**options), &block)
    end

    def ui_field_legend(**options, &block)
      render(Ui::Field::LegendComponent.new(**options), &block)
    end

    def ui_field_group(**options, &block)
      render(Ui::Field::GroupComponent.new(**options), &block)
    end

    def ui_field_content(**options, &block)
      render(Ui::Field::ContentComponent.new(**options), &block)
    end

    def ui_field_label(**options, &block)
      render(Ui::Field::LabelComponent.new(**options), &block)
    end

    def ui_field_title(**options, &block)
      render(Ui::Field::TitleComponent.new(**options), &block)
    end

    def ui_field_description(**options, &block)
      render(Ui::Field::DescriptionComponent.new(**options), &block)
    end

    def ui_field_separator(**options, &block)
      render(Ui::Field::SeparatorComponent.new(**options), &block)
    end

    def ui_field_error(**options, &block)
      render(Ui::Field::ErrorComponent.new(**options), &block)
    end
  end
end
