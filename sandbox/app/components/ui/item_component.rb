# frozen_string_literal: true

module Ui
  # A flexible list/row primitive: media + content (title/description) + actions.
  # Render as a link or button with `tag:`. Group rows with `Ui::Item::GroupComponent`.
  class ItemComponent < UiComponent
    VARIANTS = {
      default: "bg-transparent",
      outline: "border-border",
      muted: "bg-muted/50"
    }.freeze

    SIZES = {
      default: "gap-4 p-4",
      sm: "gap-2.5 px-4 py-3"
    }.freeze

    def initialize(tag: :div, variant: :default, size: :default, class_name: nil, **attrs)
      @tag = tag
      @variant = variant
      @size = size
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      content_tag_for(@tag, content)
    end

    private

    def content_tag_for(name, body)
      tag.public_send(name, body, **item_attrs)
    end

    def item_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(
          base_classes,
          fetch_variant(VARIANTS, @variant, fallback: :default),
          fetch_variant(SIZES, @size, fallback: :default),
          @class_name
        )
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "item", variant: @variant.to_s, size: @size.to_s)
      end
    end

    def base_classes
      "group/item flex flex-wrap items-center rounded-md border border-transparent text-sm outline-none transition-colors duration-100 focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] [a]:hover:bg-accent/50 [a]:transition-colors"
    end
  end
end
