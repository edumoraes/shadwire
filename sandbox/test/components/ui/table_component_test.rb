# frozen_string_literal: true

require "test_helper"

class TableComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_table do
        ui_table_caption { "Faturas recentes" } +
          ui_table_header do
            ui_table_row do
              ui_table_head(scope: "col") { "Fatura" } + ui_table_head(scope: "col") { "Valor" }
            end
          end +
          ui_table_body do
            ui_table_row do
              ui_table_cell { "INV001" } + ui_table_cell { "R$ 250,00" }
            end
          end +
          ui_table_footer do
            ui_table_row do
              ui_table_cell { "Total" } + ui_table_cell { "R$ 250,00" }
            end
          end
      end
    end
  end

  def test_renders_table_inside_scroll_container
    render_inline(Ui::TableComponent.new) { "" }

    assert_selector "div[data-slot='table-container'].overflow-x-auto > table[data-slot='table'].w-full.caption-bottom"
  end

  def test_accepts_class_alias_and_html_attrs_on_table
    render_inline(Ui::TableComponent.new(class: "min-w-[40rem]", data: { testid: "invoices" })) { "" }

    assert_selector "table.min-w-\\[40rem\\][data-testid='invoices']"
  end

  def test_renders_full_anatomy_with_helpers
    render_inline(HelperHarnessComponent.new)

    assert_selector "table caption[data-slot='table-caption']", text: "Faturas recentes"
    assert_selector "table thead[data-slot='table-header'] tr[data-slot='table-row'] th[data-slot='table-head'][scope='col']", text: "Fatura"
    assert_selector "table tbody[data-slot='table-body'] tr td[data-slot='table-cell']", text: "INV001"
    assert_selector "table tfoot[data-slot='table-footer'] td", text: "Total"
  end

  def test_row_exposes_selected_state_styling
    view = vc_test_controller.view_context
    row = Ui::Table::RowComponent.new(data: { state: "selected" }).render_in(view) do
      Ui::Table::CellComponent.new.render_in(view) { "Selecionada" }
    end
    body = Ui::Table::BodyComponent.new.render_in(view) { row }

    render_inline(Ui::TableComponent.new) { body }

    assert_selector "tr[data-state='selected'][data-slot='table-row']", text: "Selecionada"
  end
end
