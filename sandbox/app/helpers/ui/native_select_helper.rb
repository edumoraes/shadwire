# frozen_string_literal: true

module Ui
  module NativeSelectHelper
    def ui_native_select(**options, &block)
      render(Ui::NativeSelectComponent.new(**options), &block)
    end
  end
end
