# frozen_string_literal: true

module Ui
  class BreadcrumbComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.nav(content, **breadcrumb_attrs)
    end

    private

    def breadcrumb_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(@class_name)
        attrs[:aria] = { label: "breadcrumb" }.merge(attrs.fetch(:aria, {}))
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "breadcrumb")
      end
    end
  end
end
