# frozen_string_literal: true

module Ui
  module ResizableHelper
    def ui_resizable_panel_group(**options, &block)
      render(Ui::ResizablePanelGroupComponent.new(**options), &block)
    end

    def ui_resizable_panel(**options, &block)
      render(Ui::ResizablePanelComponent.new(**options), &block)
    end

    def ui_resizable_handle(**options)
      render(Ui::ResizableHandleComponent.new(**options))
    end
  end
end
