# frozen_string_literal: true

require "test_helper"

class CommandComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_command do
        ui_command_input(placeholder: "Buscar...") +
          ui_command_list do
            ui_command_empty { "Nada encontrado." } +
              ui_command_group(heading: "Sugestões") do
                ui_command_item(value: "calendario") { "Calendário" } +
                  ui_command_item(value: "perfil") { "Perfil" }
              end
          end
      end
    end
  end

  def test_root_wires_controller
    render_inline(Ui::CommandComponent.new) { "x" }

    assert_selector "[data-controller='ui-command'][data-slot='command']", text: "x"
  end

  def test_input_filters
    render_inline(Ui::Command::InputComponent.new(placeholder: "Buscar"))

    assert_selector "[data-slot='command-input-wrapper'] svg[aria-hidden='true']"
    assert_selector "input[role='combobox'][data-ui-command-target='input'][data-action='input->ui-command#filter keydown->ui-command#keydown'][placeholder='Buscar']"
  end

  def test_item_is_option_with_value
    render_inline(Ui::Command::ItemComponent.new(value: "perfil")) { "Perfil" }

    assert_selector "div[role='option'][data-value='perfil'][aria-selected='false'][data-ui-command-target='item'][data-action='click->ui-command#select']", text: "Perfil"
  end

  def test_empty_is_hidden_initially
    render_inline(Ui::Command::EmptyComponent.new) { "Nada" }

    assert_selector "div[hidden][data-slot='command-empty'][data-ui-command-target='empty']", visible: :all, text: "Nada"
  end

  def test_helper_composes_command
    render_inline(HelperHarnessComponent.new)

    assert_selector "[data-controller='ui-command'] [role='listbox'][data-ui-command-target='list']"
    assert_selector "[data-slot='command-group'][data-ui-command-target='group']", text: /Sugestões/
    assert_selector "[role='option'][data-ui-command-target='item']", count: 2
  end
end
