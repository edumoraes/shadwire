# frozen_string_literal: true

require "test_helper"

class PaginationComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_pagination do
        ui_pagination_content do
          ui_pagination_item { ui_pagination_previous(href: "#prev") } +
            ui_pagination_item { ui_pagination_link(href: "#1") { "1" } } +
            ui_pagination_item { ui_pagination_link(href: "#2", active: true) { "2" } } +
            ui_pagination_item { ui_pagination_ellipsis } +
            ui_pagination_item { ui_pagination_next(href: "#next") }
        end
      end
    end
  end

  def test_renders_navigation_landmark
    render_inline(Ui::PaginationComponent.new) { "páginas" }

    assert_selector "nav[role='navigation'][aria-label='pagination'][data-slot='pagination']", text: "páginas"
  end

  def test_renders_content_list_and_item
    view = vc_test_controller.view_context
    item = Ui::Pagination::ItemComponent.new.render_in(view) { "1" }

    render_inline(Ui::Pagination::ContentComponent.new) { item }

    assert_selector "ul[data-slot='pagination-content'] li[data-slot='pagination-item']", text: "1"
  end

  def test_active_link_uses_outline_variant_and_aria_current
    render_inline(Ui::Pagination::LinkComponent.new(href: "#2", active: true)) { "2" }

    assert_selector "a[href='#2'][aria-current='page'][data-active][data-slot='pagination-link'].border.bg-background", text: "2"
  end

  def test_inactive_link_uses_ghost_variant
    render_inline(Ui::Pagination::LinkComponent.new(href: "#3")) { "3" }

    assert_selector "a[href='#3'][data-slot='pagination-link'].hover\\:bg-accent", text: "3"
    assert_no_selector "a[aria-current]"
  end

  def test_previous_and_next_render_labels_and_icons
    view = vc_test_controller.view_context
    previous_html = Ui::Pagination::PreviousComponent.new(href: "#prev").render_in(view)
    next_html = Ui::Pagination::NextComponent.new(href: "#next").render_in(view)

    render_inline(Ui::PaginationComponent.new) { previous_html + next_html }

    assert_selector "a[href='#prev'][aria-label='Ir para a página anterior'] svg"
    assert_selector "a[href='#prev'] span.hidden", text: "Anterior"
    assert_selector "a[href='#next'][aria-label='Ir para a próxima página'] svg"
    assert_selector "a[href='#next'] span.hidden", text: "Próxima"
  end

  def test_ellipsis_is_decorative_with_sr_only_text
    render_inline(Ui::Pagination::EllipsisComponent.new)

    assert_selector "span[aria-hidden='true'][data-slot='pagination-ellipsis'] svg"
    assert_selector "span.sr-only", text: "Mais páginas"
  end

  def test_helper_methods_render_pagination
    render_inline(HelperHarnessComponent.new)

    assert_selector "nav[aria-label='pagination'] ul li", count: 5
    assert_selector "a[aria-current='page']", text: "2"
    assert_selector "[data-slot='pagination-ellipsis']"
  end
end
