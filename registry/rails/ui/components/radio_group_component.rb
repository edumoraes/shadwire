# frozen_string_literal: true

module Ui
  # Groups native radio inputs. Items sharing the same `name:` get the
  # browser's arrow-key navigation for free; label the group through
  # `aria: { label: }` or `aria: { labelledby: }`.
  class RadioGroupComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **group_attrs)
    end

    private

    def group_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:role] = attrs.fetch(:role, "radiogroup")
        attrs[:class] = group_classes
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "radio-group")
      end
    end

    def group_classes
      class_names("grid gap-3", @class_name)
    end
  end
end
