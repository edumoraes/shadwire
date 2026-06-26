# frozen_string_literal: true

module Ui
  # A full client-side data table built on the Table, Button, Input, Checkbox
  # and DropdownMenu primitives, driven by the `ui-data-table` controller:
  # text filtering, column sorting, pagination, row selection and column
  # visibility — no data library, the controller is the engine.
  #
  #   ui_data_table(
  #     columns: [
  #       { key: :name, label: "Nome", sortable: true },
  #       { key: :email, label: "E-mail" },
  #       { key: :amount, label: "Valor", sortable: true }
  #     ],
  #     rows: [{ id: 1, name: "Ada", email: "ada@x.com", amount: 316 }],
  #     filter_key: :email
  #   )
  #
  # Sort/filter read each body cell's `data-sort-value` (falling back to its
  # text), so pre-format display values as strings while keeping raw values
  # sortable via the `sort_value:` per-column key if needed.
  class DataTableComponent < UiComponent
    def initialize(
      columns:,
      rows:,
      filter_key: nil,
      filter_placeholder: "Filtrar…",
      page_size: 5,
      selectable: true,
      empty_text: "Sem resultados.",
      class_name: nil,
      **attrs
    )
      @columns = columns.map { |column| column.symbolize_keys }
      @rows = rows.map { |row| row.symbolize_keys }
      @filter_key = filter_key&.to_sym
      @filter_placeholder = filter_placeholder
      @page_size = page_size
      @selectable = selectable
      @empty_text = empty_text
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    private

    def root_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("w-full", @class_name)
        attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
          data[:slot] = "data-table"
          data[:controller] = append_token(data[:controller], "ui-data-table")
          data[:"ui-data-table-page-size-value"] = @page_size
          data[:"ui-data-table-filter-key-value"] = @filter_key if @filter_key
        end
      end
    end

    def column_count
      @columns.size + (@selectable ? 1 : 0)
    end

    def cell_value(row, column)
      row[column[:key]]
    end

    def sort_value(row, column)
      column.key?(:sort_value) ? row[column[:sort_value]] : cell_value(row, column)
    end

    def row_identifier(row, index)
      row.fetch(:id, index)
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
