# frozen_string_literal: true

require "test_helper"

class EmptyComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_empty do
        ui_empty_header do
          ui_empty_media(variant: :icon) { "I" } +
            ui_empty_title { "No projects" } +
            ui_empty_description { "Create your first project to get started." }
        end +
          ui_empty_content { "actions" }
      end
    end
  end

  def test_root_renders_dashed_container
    render_inline(Ui::EmptyComponent.new) { "x" }

    assert_selector "div[data-slot='empty'].border-dashed.text-center", text: "x"
  end

  def test_media_icon_variant
    render_inline(Ui::Empty::MediaComponent.new(variant: :icon)) { "I" }

    assert_selector "div[data-slot='empty-media'][data-variant='icon'].bg-muted.rounded-lg", text: "I"
  end

  def test_helper_composes_full_empty_state
    render_inline(HelperHarnessComponent.new)

    assert_selector "div[data-slot='empty'] div[data-slot='empty-header']"
    assert_selector "div[data-slot='empty-title']", text: "No projects"
    assert_selector "p[data-slot='empty-description']", text: /Create your first/
    assert_selector "div[data-slot='empty-content']", text: "actions"
  end
end
