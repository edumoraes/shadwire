# frozen_string_literal: true

module Ui
  module CalendarHelper
    def ui_calendar(**options)
      render(Ui::CalendarComponent.new(**options))
    end
  end
end
