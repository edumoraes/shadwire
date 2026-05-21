# frozen_string_literal: true

module Ui
  module Card
    class FooterComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs, class: class_names("flex items-center p-6 pt-0", @class_name))
      end
    end
  end
end
