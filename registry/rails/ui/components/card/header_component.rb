# frozen_string_literal: true

module Ui
  module Card
    class HeaderComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs, class: class_names("flex flex-col gap-1.5 p-6", @class_name))
      end
    end
  end
end
