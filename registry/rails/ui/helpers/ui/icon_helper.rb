# frozen_string_literal: true

module Ui
  module IconHelper
    def ui_icon(name, **options)
      render(Ui::IconComponent.new(name, **options))
    end
  end
end
