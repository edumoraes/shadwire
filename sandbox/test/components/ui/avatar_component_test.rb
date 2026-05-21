# frozen_string_literal: true

require "test_helper"

class AvatarComponentTest < ViewComponent::TestCase
  def test_renders_avatar_with_image_and_fallback
    render_inline(Ui::AvatarComponent.new(src: "/avatar.png", alt: "Ada Lovelace", fallback: "AL"))

    assert_selector "span.relative.flex.size-10"
    assert_selector "img[src='/avatar.png'][alt='Ada Lovelace']"
    assert_selector "span.bg-muted", text: "AL"
  end

  def test_renders_content_block
    render_inline(Ui::AvatarComponent.new(class: "size-12")) { "Custom" }

    assert_selector "span.size-12", text: "Custom"
  end
end
