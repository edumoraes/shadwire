# frozen_string_literal: true

module Ui
  module EmptyHelper
    def ui_empty(**options, &block)
      render(Ui::EmptyComponent.new(**options), &block)
    end

    def ui_empty_header(**options, &block)
      render(Ui::Empty::HeaderComponent.new(**options), &block)
    end

    def ui_empty_media(**options, &block)
      render(Ui::Empty::MediaComponent.new(**options), &block)
    end

    def ui_empty_title(**options, &block)
      render(Ui::Empty::TitleComponent.new(**options), &block)
    end

    def ui_empty_description(**options, &block)
      render(Ui::Empty::DescriptionComponent.new(**options), &block)
    end

    def ui_empty_content(**options, &block)
      render(Ui::Empty::ContentComponent.new(**options), &block)
    end
  end
end
