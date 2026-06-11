# frozen_string_literal: true

require "test_helper"

class SkeletonComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_skeleton(class: "h-4 w-48")
    end
  end

  def test_renders_decorative_placeholder
    render_inline(Ui::SkeletonComponent.new(class: "h-4 w-32"))

    assert_selector "div[data-slot='skeleton'][aria-hidden='true'].animate-pulse.bg-accent.rounded-md.h-4.w-32"
  end

  def test_allows_exposing_to_assistive_technology
    render_inline(Ui::SkeletonComponent.new(aria: { hidden: "false", label: "Carregando" }))

    assert_selector "div[aria-hidden='false'][aria-label='Carregando']"
  end

  def test_accepts_html_attrs_and_content
    render_inline(Ui::SkeletonComponent.new(data: { testid: "loading" })) { "conteúdo" }

    assert_selector "div[data-testid='loading'][data-slot='skeleton']", text: "conteúdo"
  end

  def test_helper_renders_skeleton
    render_inline(HelperHarnessComponent.new)

    assert_selector "div[data-slot='skeleton'].h-4.w-48"
  end
end
