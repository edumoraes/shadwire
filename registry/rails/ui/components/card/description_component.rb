# frozen_string_literal: true

module Ui
  module Card
    class DescriptionComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.p(content, **html_attrs, class: class_names("text-sm text-muted-foreground", @class_name))
      end
    end
  end
end
