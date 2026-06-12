# frozen_string_literal: true

require "test_helper"

class SelectComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_select(name: "fruit", value: "banana", placeholder: "Selecione uma fruta", id: "fruit-select") do
        safe_join(
          [
            ui_select_trigger { ui_select_value },
            ui_select_content do
              ui_select_group do
                ui_select_label { "Frutas" } +
                  ui_select_item(value: "apple") { "Maçã" } +
                  ui_select_item(value: "banana") { "Banana" } +
                  ui_select_item(value: "cherry", disabled: true) { "Cereja" }
              end
            end
          ]
        )
      end
    end
  end

  def test_root_renders_controller_values_and_hidden_input
    render_inline(Ui::SelectComponent.new(name: "fruit", value: "banana", placeholder: "Escolha")) { "x" }

    assert_selector "[data-controller='ui-select'][data-slot='select'][data-ui-select-value-value='banana']" \
                    "[data-ui-select-placeholder-value='Escolha'].relative"
    assert_selector "[data-action='click@window->ui-select#outsideClick']"
    assert_selector "input[type='hidden'][name='fruit'][value='banana'][data-ui-select-target='input']", visible: :all
  end

  def test_trigger_renders_combobox_with_chevron
    render_inline(Ui::Select::TriggerComponent.new) { "Selecione" }

    assert_selector "button[type='button'][role='combobox'][aria-haspopup='listbox'][aria-expanded='false']" \
                    "[data-slot='select-trigger'][data-ui-select-target='trigger']" \
                    "[data-action='click->ui-select#toggle keydown->ui-select#keydown']", text: "Selecione"
    assert_selector "button svg" # chevron-down
  end

  def test_trigger_small_size
    render_inline(Ui::Select::TriggerComponent.new(size: :sm)) { "x" }

    assert_selector "button.h-8"
  end

  def test_value_renders_target_span
    render_inline(Ui::Select::ValueComponent.new)

    assert_selector "span[data-slot='select-value'][data-ui-select-target='value']"
  end

  def test_content_renders_hidden_listbox
    render_inline(Ui::Select::ContentComponent.new) { "opções" }

    assert_selector "div[role='listbox'][hidden][data-slot='select-content'][data-ui-select-target='content']",
                    visible: :all, text: "opções"
  end

  def test_item_renders_option_with_value_and_actions
    render_inline(Ui::Select::ItemComponent.new(value: "apple")) { "Maçã" }

    assert_selector "div[role='option'][data-value='apple'][data-slot='select-item'][data-ui-select-target='item']" \
                    "[data-action='click->ui-select#select mouseenter->ui-select#highlight']", text: "Maçã"
  end

  def test_item_disabled_state
    render_inline(Ui::Select::ItemComponent.new(value: "cherry", disabled: true)) { "Cereja" }

    assert_selector "div[role='option'][data-disabled][aria-disabled='true']", text: "Cereja"
  end

  def test_group_label_and_separator
    render_inline(Ui::Select::GroupComponent.new) { "g" }
    assert_selector "div[role='group'][data-slot='select-group']", text: "g"

    render_inline(Ui::Select::LabelComponent.new) { "Frutas" }
    assert_selector "div[data-slot='select-label'].text-muted-foreground", text: "Frutas"

    render_inline(Ui::Select::SeparatorComponent.new)
    assert_selector "div[role='separator'][data-slot='select-separator']"
  end

  def test_helper_methods_render_select
    render_inline(HelperHarnessComponent.new)

    assert_selector "#fruit-select[data-controller='ui-select'][data-ui-select-value-value='banana']"
    assert_selector "input[type='hidden'][name='fruit'][value='banana']", visible: :all
    assert_selector "button[role='combobox'] span[data-ui-select-target='value']"
    assert_selector "[role='listbox'] [role='group'] [data-slot='select-label']", visible: :all, text: "Frutas"
    assert_selector "[role='listbox'] [role='option'][data-value='banana']", visible: :all, text: "Banana"
    assert_selector "[role='listbox'] [role='option'][data-disabled][data-value='cherry']", visible: :all, text: "Cereja"
  end
end
