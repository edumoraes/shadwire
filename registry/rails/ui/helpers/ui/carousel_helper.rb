# frozen_string_literal: true

module Ui
  module CarouselHelper
    def ui_carousel(**options, &block)
      render(Ui::CarouselComponent.new(**options), &block)
    end

    def ui_carousel_content(**options, &block)
      render(Ui::Carousel::ContentComponent.new(**options), &block)
    end

    def ui_carousel_item(**options, &block)
      render(Ui::Carousel::ItemComponent.new(**options), &block)
    end

    def ui_carousel_previous(**options)
      render(Ui::Carousel::PreviousComponent.new(**options))
    end

    def ui_carousel_next(**options)
      render(Ui::Carousel::NextComponent.new(**options))
    end
  end
end
