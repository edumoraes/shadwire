# frozen_string_literal: true

require "test_helper"

class FieldComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_field_group do
        ui_field do
          ui_field_label(for: "email") { "Email" } +
            ui_input(type: :email, id: "email") +
            ui_field_description { "We never share it." }
        end +
          ui_field(orientation: :horizontal, invalid: true) do
            ui_field_error { "Required" }
          end
      end
    end
  end

  def test_root_defaults_to_vertical_group
    render_inline(Ui::FieldComponent.new) { "x" }

    assert_selector "div[role='group'][data-slot='field'][data-orientation='vertical']", text: "x"
  end

  def test_invalid_sets_data_invalid
    render_inline(Ui::FieldComponent.new(orientation: :horizontal, invalid: true)) { "x" }

    assert_selector "div[data-slot='field'][data-orientation='horizontal'][data-invalid='true']"
  end

  def test_set_and_legend
    render_inline(Ui::Field::LegendComponent.new(variant: :label)) { "Account" }

    assert_selector "legend[data-slot='field-legend'][data-variant='label'].text-sm", text: "Account"
  end

  def test_error_renders_alert_and_skips_when_empty
    render_inline(Ui::Field::ErrorComponent.new(errors: [ "A", "B" ]))

    assert_selector "div[role='alert'][data-slot='field-error'] ul li", count: 2

    render_inline(Ui::Field::ErrorComponent.new)
    assert_no_selector "[data-slot='field-error']"
  end

  def test_helper_composes_field_group
    render_inline(HelperHarnessComponent.new)

    assert_selector "div[data-slot='field-group'] div[data-slot='field']"
    assert_selector "label[data-slot='field-label'][for='email']", text: "Email"
    assert_selector "p[data-slot='field-description']", text: /never share/
    assert_selector "div[data-slot='field'][data-invalid='true'] [data-slot='field-error']", text: "Required"
  end
end
