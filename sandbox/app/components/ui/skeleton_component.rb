# frozen_string_literal: true

module Ui
  # A loading placeholder, hidden from assistive technology by default;
  # override with `aria: { hidden: "false" }` plus a label when it conveys
  # loading state on its own.
  class SkeletonComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **skeleton_attrs)
    end

    private

    def skeleton_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = skeleton_classes
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "skeleton")
        attrs[:aria] = { hidden: "true" }.merge(attrs.fetch(:aria, {}))
      end
    end

    def skeleton_classes
      class_names("bg-accent animate-pulse rounded-md", @class_name)
    end
  end
end
