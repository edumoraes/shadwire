# frozen_string_literal: true

module Ui
  module SkeletonHelper
    def ui_skeleton(**options, &block)
      render(Ui::SkeletonComponent.new(**options), &block)
    end
  end
end
