# frozen_string_literal: true

require "test_helper"

class DataTableComponentTest < ViewComponent::TestCase
  COLUMNS = [
    { key: :name, label: "Nome", sortable: true },
    { key: :email, label: "E-mail" },
    { key: :amount, label: "Valor", sortable: true }
  ].freeze

  ROWS = [
    { id: 1, name: "Ada", email: "ada@example.com", amount: 316 },
    { id: 2, name: "Linus", email: "linus@example.com", amount: 242 }
  ].freeze

  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_data_table(columns: DataTableComponentTest::COLUMNS, rows: DataTableComponentTest::ROWS, filter_key: :email)
    end
  end

  def render_table(**options)
    render_inline(Ui::DataTableComponent.new(columns: COLUMNS, rows: ROWS, **options))
  end

  def test_root_wires_the_controller_with_page_size
    render_table(page_size: 5, filter_key: :email)

    assert_selector "div[data-slot='data-table'][data-controller='ui-data-table']" \
                    "[data-ui-data-table-page-size-value='5'][data-ui-data-table-filter-key-value='email']"
  end

  def test_filter_input_targets_and_fires_filter
    render_table(filter_key: :email)

    assert_selector "input[type='search'][data-ui-data-table-target='filter'][data-action='input->ui-data-table#filter']"
  end

  def test_filter_input_is_omitted_without_a_filter_key
    render_table

    assert_no_selector "input[data-ui-data-table-target='filter']"
  end

  def test_column_visibility_menu_lists_each_column
    render_table

    assert_selector "[data-slot='dropdown-menu'] [role='menuitemcheckbox'][aria-checked='true'][data-action*='click->ui-data-table#toggleColumn']", count: 3, visible: :all
    assert_selector "[role='menuitemcheckbox'][data-column='name']", text: "Nome", visible: :all
  end

  def test_select_all_checkbox_in_header
    render_table

    assert_selector "thead th input[type='checkbox'][data-ui-data-table-target='selectAll'][data-action='change->ui-data-table#toggleAll']"
  end

  def test_sortable_header_renders_a_sort_button_and_aria_sort
    render_table

    assert_selector "th[data-column='name'][aria-sort='none'] button[data-ui-data-table-target='columnHeader'][data-column='name'][data-action='click->ui-data-table#sort']", text: "Nome"
    assert_selector "th[data-column='email']:not([aria-sort])", text: "E-mail"
  end

  def test_body_rows_carry_targets_and_sortable_cells
    render_table

    assert_selector "tbody tr[data-ui-data-table-target='row'][data-row-id='1']"
    assert_selector "tbody tr[data-row-id='1'] td[data-column='amount'][data-sort-value='316']", text: "316"
    assert_selector "tbody tr[data-row-id='1'] input[type='checkbox'][data-ui-data-table-target='rowCheckbox'][data-action='change->ui-data-table#toggleRow']"
  end

  def test_empty_state_row_is_hidden_and_spans_all_columns
    render_table

    assert_selector "tr[data-ui-data-table-target='emptyState'][hidden] td[colspan='4']", text: "Sem resultados.", visible: :all
  end

  def test_footer_has_selection_info_and_pagination
    render_table

    assert_selector "[data-ui-data-table-target='selectionInfo']"
    assert_selector "[data-ui-data-table-target='pageInfo']"
    assert_selector "button[data-ui-data-table-target='previous'][data-action='click->ui-data-table#previousPage']", text: "Anterior"
    assert_selector "button[data-ui-data-table-target='next'][data-action='click->ui-data-table#nextPage']", text: "Próximo"
  end

  def test_helper_composes_the_data_table
    render_inline(HelperHarnessComponent.new)

    assert_selector "div[data-controller='ui-data-table'] tbody tr[data-ui-data-table-target='row']", count: 2
  end
end
