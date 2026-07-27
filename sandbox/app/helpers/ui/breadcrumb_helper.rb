# frozen_string_literal: true

module Ui
  module BreadcrumbHelper
    def ui_breadcrumb(**options, &block)
      render(Ui::BreadcrumbComponent.new(**options), &block)
    end

    def ui_breadcrumb_list(**options, &block)
      render(Ui::Breadcrumb::ListComponent.new(**options), &block)
    end

    def ui_breadcrumb_item(**options, &block)
      render(Ui::Breadcrumb::ItemComponent.new(**options), &block)
    end

    def ui_breadcrumb_link(**options, &block)
      render(Ui::Breadcrumb::LinkComponent.new(**options), &block)
    end

    def ui_breadcrumb_page(**options, &block)
      render(Ui::Breadcrumb::PageComponent.new(**options), &block)
    end

    def ui_breadcrumb_separator(**options, &block)
      render(Ui::Breadcrumb::SeparatorComponent.new(**options), &block)
    end

    def ui_breadcrumb_ellipsis(**options)
      render(Ui::Breadcrumb::EllipsisComponent.new(**options))
    end
  end
end
