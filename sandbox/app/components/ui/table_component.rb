# frozen_string_literal: true

module Ui
  # Wraps the table in a scroll container so wide tables overflow
  # horizontally instead of breaking the layout.
  class TableComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(class: "relative w-full overflow-x-auto", data: { slot: "table-container" }) do
        tag.table(content, **table_attrs)
      end
    end

    private

    def table_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("w-full caption-bottom text-sm", @class_name)
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "table")
      end
    end
  end
end
