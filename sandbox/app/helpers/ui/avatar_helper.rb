# frozen_string_literal: true

module Ui
  module AvatarHelper
    def ui_avatar(**options, &block)
      render(Ui::AvatarComponent.new(**options), &block)
    end
  end
end
