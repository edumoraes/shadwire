# frozen_string_literal: true

require "test_helper"

class SheetComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include Ui::SheetHelper

    def call
      ui_sheet(id: "filters-sheet") do
        ui_sheet_trigger(variant: :outline) { "Abrir filtros" } +
          ui_sheet_content(side: :left) do
            ui_sheet_header do
              ui_sheet_title { "Filtros" } + ui_sheet_description { "Refine os resultados." }
            end +
              ui_sheet_footer do
                ui_sheet_close { "Aplicar" }
              end
          end
      end
    end
  end

  def test_root_renders_shared_dialog_controller
    render_inline(Ui::SheetComponent.new) { "x" }

    assert_selector "[data-controller='ui-dialog'][data-slot='sheet']"
  end

  def test_content_defaults_to_right_side
    render_inline(Ui::Sheet::ContentComponent.new) { "Corpo" }

    assert_selector "dialog[data-slot='sheet-content'][data-side='right'][data-ui-dialog-target='dialog'].border-l",
                    visible: :all, text: "Corpo"
    assert_selector "dialog[data-action='click->ui-dialog#backdropClick cancel->ui-dialog#cancel close->ui-dialog#closed']",
                    visible: :all
    assert_selector "dialog [data-slot='sheet-close-x'] span.sr-only", visible: :all, text: "Close"
  end

  def test_content_side_variants
    render_inline(Ui::Sheet::ContentComponent.new(side: :top)) { "x" }

    assert_selector "dialog[data-side='top'].border-b", visible: :all

    render_inline(Ui::Sheet::ContentComponent.new(side: :bottom)) { "x" }

    assert_selector "dialog[data-side='bottom'].border-t", visible: :all

    render_inline(Ui::Sheet::ContentComponent.new(side: :left)) { "x" }

    assert_selector "dialog[data-side='left'].border-r", visible: :all
  end

  def test_header_title_description_and_footer
    view = vc_test_controller.view_context
    header = Ui::Sheet::HeaderComponent.new.render_in(view) do
      Ui::Sheet::TitleComponent.new.render_in(view) { "Title" } +
        Ui::Sheet::DescriptionComponent.new.render_in(view) { "Description" }
    end
    footer = Ui::Sheet::FooterComponent.new.render_in(view) { "actions" }

    render_inline(Ui::Sheet::ContentComponent.new) { header + footer }

    assert_selector "dialog [data-slot='sheet-header'] h2[data-slot='sheet-title']", visible: :all, text: "Title"
    assert_selector "dialog p[data-slot='sheet-description']", visible: :all, text: "Description"
    assert_selector "dialog [data-slot='sheet-footer']", visible: :all, text: "actions"
  end

  def test_trigger_and_close_buttons
    render_inline(Ui::Sheet::TriggerComponent.new) { "Open" }

    assert_selector "button[aria-haspopup='dialog'][data-slot='sheet-trigger'][data-action='click->ui-dialog#open']",
                    text: "Open"

    render_inline(Ui::Sheet::CloseComponent.new) { "Close" }

    assert_selector "button[data-slot='sheet-close'][data-action='click->ui-dialog#close'].border", text: "Close"
  end

  def test_helper_methods_render_sheet
    render_inline(HelperHarnessComponent.new)

    assert_selector "#filters-sheet[data-controller='ui-dialog']"
    assert_selector "dialog[data-side='left'] h2[data-slot='sheet-title']", visible: :all, text: "Filtros"
    assert_selector "dialog [data-slot='sheet-footer'] button", visible: :all, text: "Aplicar"
  end
end
