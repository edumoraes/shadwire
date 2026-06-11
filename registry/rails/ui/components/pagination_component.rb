# frozen_string_literal: true

module Ui
  class PaginationComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.nav(content, **pagination_attrs)
    end

    private

    def pagination_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:role] = attrs.fetch(:role, "navigation")
        attrs[:class] = class_names("mx-auto flex w-full justify-center", @class_name)
        attrs[:aria] = { label: "pagination" }.merge(attrs.fetch(:aria, {}))
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "pagination")
      end
    end
  end
end
