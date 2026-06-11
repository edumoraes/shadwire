# frozen_string_literal: true

require "test_helper"

class BreadcrumbComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_breadcrumb do
        ui_breadcrumb_list do
          ui_breadcrumb_item { ui_breadcrumb_link(href: "/") { "Início" } } +
            ui_breadcrumb_separator +
            ui_breadcrumb_item { ui_breadcrumb_ellipsis } +
            ui_breadcrumb_separator(class_name: nil) { "/".html_safe } +
            ui_breadcrumb_item { ui_breadcrumb_page { "Breadcrumb" } }
        end
      end
    end
  end

  def test_renders_nav_with_breadcrumb_label
    render_inline(Ui::BreadcrumbComponent.new) { "trilha" }

    assert_selector "nav[aria-label='breadcrumb'][data-slot='breadcrumb']", text: "trilha"
  end

  def test_renders_list_item_and_link
    view = vc_test_controller.view_context
    link = Ui::Breadcrumb::LinkComponent.new(href: "/docs").render_in(view) { "Docs" }
    item = Ui::Breadcrumb::ItemComponent.new.render_in(view) { link }
    list = Ui::Breadcrumb::ListComponent.new.render_in(view) { item }

    render_inline(Ui::BreadcrumbComponent.new) { list }

    assert_selector "nav ol[data-slot='breadcrumb-list'] li[data-slot='breadcrumb-item'] a[href='/docs'][data-slot='breadcrumb-link']", text: "Docs"
  end

  def test_page_marks_current_location
    render_inline(Ui::Breadcrumb::PageComponent.new) { "Atual" }

    assert_selector "span[role='link'][aria-disabled='true'][aria-current='page'][data-slot='breadcrumb-page']", text: "Atual"
  end

  def test_separator_defaults_to_chevron_icon_and_accepts_custom_content
    render_inline(Ui::Breadcrumb::SeparatorComponent.new)

    assert_selector "li[role='presentation'][aria-hidden='true'][data-slot='breadcrumb-separator'] svg"
  end

  def test_separator_with_custom_content
    render_inline(Ui::Breadcrumb::SeparatorComponent.new) { "/" }

    assert_selector "li[role='presentation'][aria-hidden='true']", text: "/"
    assert_no_selector "li[data-slot='breadcrumb-separator'] svg"
  end

  def test_ellipsis_is_presentational
    render_inline(Ui::Breadcrumb::EllipsisComponent.new)

    assert_selector "span[role='presentation'][aria-hidden='true'][data-slot='breadcrumb-ellipsis'] svg"
    assert_selector "span.sr-only", text: "Mais"
  end

  def test_helper_methods_render_breadcrumb_trail
    render_inline(HelperHarnessComponent.new)

    assert_selector "nav[aria-label='breadcrumb'] ol li a[href='/']", text: "Início"
    assert_selector "nav li[data-slot='breadcrumb-separator']", count: 2
    assert_selector "nav span[aria-current='page']", text: "Breadcrumb"
  end
end
