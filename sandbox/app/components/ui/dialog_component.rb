# frozen_string_literal: true

module Ui
  class DialogComponent < UiComponent
    def initialize(close_on_backdrop: true, class_name: nil, **attrs)
      @close_on_backdrop = close_on_backdrop
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **dialog_attrs)
    end

    private

    def dialog_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(@class_name)
        attrs[:data] = dialog_data(attrs[:data])
      end
    end

    def dialog_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "dialog"
        data[:controller] = append_token(data[:controller], "ui-dialog")
        data[:ui_dialog_close_on_backdrop_value] = false unless @close_on_backdrop
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
