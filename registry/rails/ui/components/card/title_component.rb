# frozen_string_literal: true

module Ui
  module Card
    class TitleComponent < UiComponent
      # `tag_name:` is what this argument was called before every component
      # settled on `tag:`; it still works.
      def initialize(tag: :h3, tag_name: nil, class_name: nil, **attrs)
        @tag = tag_name || tag
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag, content, **title_attrs)
      end

      private

      def title_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("text-2xl font-semibold leading-none tracking-tight", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "card-title")
        end
      end
    end
  end
end
