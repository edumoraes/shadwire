# frozen_string_literal: true

class UiComponent < ViewComponent::Base
  private

  def extract_class_name(attrs, class_name)
    [attrs.delete(:class), class_name].compact_blank.join(" ")
  end

  def fetch_variant(mapping, key, fallback:)
    variant = key.presence&.to_sym || fallback.to_sym

    mapping.fetch(variant) { mapping.fetch(fallback.to_sym) }
  end

  def html_attrs
    @attrs
  end
end
