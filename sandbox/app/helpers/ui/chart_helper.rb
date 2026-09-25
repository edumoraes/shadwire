# frozen_string_literal: true

module Ui
  module ChartHelper
    def ui_chart(**options, &block)
      render(Ui::ChartComponent.new(**options), &block)
    end

    def ui_chart_grid(**options)
      render(Ui::Chart::GridComponent.new(**options))
    end

    def ui_chart_x_axis(**options)
      render(Ui::Chart::XAxisComponent.new(**options))
    end

    def ui_chart_y_axis(**options)
      render(Ui::Chart::YAxisComponent.new(**options))
    end

    def ui_chart_bar(**options, &block)
      render(Ui::Chart::BarComponent.new(**options), &block)
    end

    def ui_chart_line(**options, &block)
      render(Ui::Chart::LineComponent.new(**options), &block)
    end

    def ui_chart_area(**options, &block)
      render(Ui::Chart::AreaComponent.new(**options), &block)
    end

    def ui_chart_pie(**options, &block)
      render(Ui::Chart::PieComponent.new(**options), &block)
    end

    def ui_chart_radial_bar(**options, &block)
      render(Ui::Chart::RadialBarComponent.new(**options), &block)
    end

    def ui_chart_radar(**options, &block)
      render(Ui::Chart::RadarComponent.new(**options), &block)
    end

    def ui_chart_polar_grid(**options)
      render(Ui::Chart::PolarGridComponent.new(**options))
    end

    def ui_chart_polar_angle_axis(**options)
      render(Ui::Chart::PolarAngleAxisComponent.new(**options))
    end

    def ui_chart_label_list(**options)
      render(Ui::Chart::LabelListComponent.new(**options))
    end

    def ui_chart_tooltip(**options)
      render(Ui::Chart::TooltipComponent.new(**options))
    end

    def ui_chart_legend(**options)
      render(Ui::Chart::LegendComponent.new(**options))
    end

    def ui_chart_layer(**options, &block)
      render(Ui::Chart::LayerComponent.new(**options), &block)
    end
  end
end
