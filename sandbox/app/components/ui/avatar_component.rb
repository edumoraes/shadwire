# frozen_string_literal: true

module Ui
  class AvatarComponent < UiComponent
    def initialize(src: nil, alt: "", fallback: nil, class_name: nil, **attrs)
      @src = src
      @alt = alt
      @fallback = fallback
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.span(**html_attrs, class: avatar_classes) do
        content.presence || safe_join([ image_tag_html, fallback_html ].compact)
      end
    end

    private

    def avatar_classes
      class_names("relative flex size-10 shrink-0 overflow-hidden rounded-full", @class_name)
    end

    def image_tag_html
      return if @src.blank?

      tag.img(src: @src, alt: @alt, class: "aspect-square size-full")
    end

    def fallback_html
      return if @fallback.blank?

      tag.span(@fallback, class: "flex size-full items-center justify-center rounded-full bg-muted")
    end
  end
end
