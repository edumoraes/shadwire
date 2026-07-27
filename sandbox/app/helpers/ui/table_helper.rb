# frozen_string_literal: true

module Ui
  module TableHelper
    def ui_table(**options, &block)
      render(Ui::TableComponent.new(**options), &block)
    end

    def ui_table_header(**options, &block)
      render(Ui::Table::HeaderComponent.new(**options), &block)
    end

    def ui_table_body(**options, &block)
      render(Ui::Table::BodyComponent.new(**options), &block)
    end

    def ui_table_footer(**options, &block)
      render(Ui::Table::FooterComponent.new(**options), &block)
    end

    def ui_table_row(**options, &block)
      render(Ui::Table::RowComponent.new(**options), &block)
    end

    def ui_table_head(**options, &block)
      render(Ui::Table::HeadComponent.new(**options), &block)
    end

    def ui_table_cell(**options, &block)
      render(Ui::Table::CellComponent.new(**options), &block)
    end

    def ui_table_caption(**options, &block)
      render(Ui::Table::CaptionComponent.new(**options), &block)
    end
  end
end
