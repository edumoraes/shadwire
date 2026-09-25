# frozen_string_literal: true

require "test_helper"
require_relative "../support/component_catalog"

# The conventions every registry component shares, checked on every component
# rather than on the ones someone remembered to test.
#
# - Every part renders a `data-slot`, as upstream does. Sixteen did not: Button,
#   Badge, the whole Card, Alert, Avatar, Separator.
# - `class:` and `class_name:` both reach the element, together.
# - Free HTML attributes pass through, `data:` and `id` included. The button
#   group and item separators dropped their own slot as soon as a caller passed
#   `data:`.
#
# One test per component (ComponentCatalog), so a new component is held to the
# same rules the day it is added.
class ComponentConventionsTest < ViewComponent::TestCase
  # The icon is lucide-rails' own <svg>; upstream's icons carry no slot either.
  NO_SLOT = %w[Ui::IconComponent].freeze

  # `data:` is the chart's Chart.js data, so HTML data attributes go in as
  # "data-*" keys — which is what this component's documentation says.
  FLAT_DATA = %w[Ui::ChartComponent].freeze

  ComponentCatalog::NAMES.each do |class_name|
    define_method("test_#{class_name.underscore.tr("/", "_")}_follows_the_conventions") do
      assert_conventions(class_name)
    end
  end

  test "every component was discovered" do
    assert_operator ComponentCatalog::NAMES.size, :>, 200
  end

  private

  def assert_conventions(class_name)
    probe = FLAT_DATA.include?(class_name) ? { "data-probe": "1" } : { data: { probe: "1" } }
    component = ComponentCatalog.build(class_name, class: "probe-class", class_name: "probe-class-name", id: "probe-id", **probe)

    fragment = render_inline(component.with_content("content"))
    root = fragment.children.find(&:element?)

    assert root, "#{class_name} rendered nothing"
    assert root["data-slot"].present?, "#{class_name} renders <#{root.name}> without a data-slot" unless NO_SLOT.include?(class_name)
    assert fragment.css(".probe-class.probe-class-name").any?, "#{class_name} does not apply class: and class_name: together"
    assert fragment.css("[data-probe='1']").any?, "#{class_name} drops the data: attributes it is given"
    assert fragment.css("#probe-id").any?, "#{class_name} drops the id it is given"
  end
end
