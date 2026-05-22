# frozen_string_literal: true

require "test_helper"

class AvatarComponentTest < ViewComponent::TestCase
  def test_renders_avatar_with_image_and_fallback
    render_inline(Ui::AvatarComponent.new(src: "/avatar.png", alt: "Ada Lovelace", fallback: "AL"))

    assert_selector "span.relative.flex.size-10"
    assert_selector "img[src='/avatar.png'][alt='Ada Lovelace']"
    assert_selector "span.bg-muted[aria-hidden='true']", text: "AL"
  end

  def test_renders_fallback_as_accessible_text_without_image
    render_inline(Ui::AvatarComponent.new(fallback: "AL"))

    assert_no_selector "img"
    assert_selector "span.bg-muted", text: "AL"
    assert_no_selector "span.bg-muted[aria-hidden]"
  end

  def test_keeps_root_span_semantics_and_free_attributes
    render_inline(
      Ui::AvatarComponent.new(
        src: "/avatar.png",
        alt: "",
        fallback: "AL",
        data: { testid: "profile-avatar" },
        aria: { label: "Perfil" }
      )
    )

    assert_selector "span.relative.flex.size-10[data-testid='profile-avatar'][aria-label='Perfil']"
    assert_no_selector "span.relative.flex.size-10[role]"
    assert_no_selector "span.relative.flex.size-10[data-status]"
    assert_no_selector "img[type]"
  end

  def test_renders_content_block
    render_inline(Ui::AvatarComponent.new(class: "size-12")) { "Custom" }

    assert_selector "span.size-12", text: "Custom"
  end
end
