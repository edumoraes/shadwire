# frozen_string_literal: true

module Ui
  module Card
    class TitleComponent < UiComponent
      def initialize(tag_name: :h3, class_name: nil, **attrs)
        @tag_name = tag_name
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag_name, content, **html_attrs, class: class_names("text-2xl font-semibold leading-none tracking-normal", @class_name))
      end
    end
  end
end
