# frozen_string_literal: true

module Ui
  module DataTableHelper
    def ui_data_table(**options)
      render(Ui::DataTableComponent.new(**options))
    end
  end
end
