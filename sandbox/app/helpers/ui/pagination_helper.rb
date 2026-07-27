# frozen_string_literal: true

module Ui
  module PaginationHelper
    def ui_pagination(**options, &block)
      render(Ui::PaginationComponent.new(**options), &block)
    end

    def ui_pagination_content(**options, &block)
      render(Ui::Pagination::ContentComponent.new(**options), &block)
    end

    def ui_pagination_item(**options, &block)
      render(Ui::Pagination::ItemComponent.new(**options), &block)
    end

    def ui_pagination_link(**options, &block)
      render(Ui::Pagination::LinkComponent.new(**options), &block)
    end

    def ui_pagination_previous(**options, &block)
      render(Ui::Pagination::PreviousComponent.new(**options), &block)
    end

    def ui_pagination_next(**options, &block)
      render(Ui::Pagination::NextComponent.new(**options), &block)
    end

    def ui_pagination_ellipsis(**options)
      render(Ui::Pagination::EllipsisComponent.new(**options))
    end
  end
end
