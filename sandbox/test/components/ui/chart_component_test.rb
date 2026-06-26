# frozen_string_literal: true

require "test_helper"

class ChartComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_chart(
        type: :line,
        data: { labels: %w[Jan Fev], datasets: [ { label: "Visitas", data: [ 12, 30 ] } ] },
        label: "Visitas por mês"
      )
    end
  end

  def test_root_is_a_chart_controller
    render_inline(Ui::ChartComponent.new(type: :line))

    assert_selector "figure[data-slot='chart'][data-controller='ui-chart'][data-ui-chart-type-value='line']"
  end

  def test_canvas_is_an_image_target
    render_inline(Ui::ChartComponent.new(label: "Receita"))

    assert_selector "figure[data-slot='chart'] canvas[role='img'][data-ui-chart-target='canvas'][aria-label='Receita']"
  end

  def test_data_and_options_are_serialized_as_json
    render_inline(Ui::ChartComponent.new(
      data: { labels: [ "A" ], datasets: [ { label: "S", data: [ 1 ] } ] },
      options: { plugins: { legend: { display: false } } }
    ))

    figure = page.find("figure")
    assert_equal [ "A" ], JSON.parse(figure["data-ui-chart-data-value"])["labels"]
    assert_equal false, JSON.parse(figure["data-ui-chart-options-value"]).dig("plugins", "legend", "display")
  end

  def test_helper_renders_a_chart
    render_inline(HelperHarnessComponent.new)

    assert_selector "figure[data-controller='ui-chart'] canvas[aria-label='Visitas por mês']"
  end
end
