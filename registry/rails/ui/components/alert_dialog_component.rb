# frozen_string_literal: true

module Ui
  # An interruption dialog that requires an explicit choice: backdrop and
  # Escape dismissal are disabled, so users must pick Cancel or Action.
  class AlertDialogComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **alert_dialog_attrs)
    end

    private

    def alert_dialog_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(@class_name)
        attrs[:data] = alert_dialog_data(attrs[:data])
      end
    end

    def alert_dialog_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "alert-dialog"
        data[:controller] = append_token(data[:controller], "ui-dialog")
        data[:ui_dialog_close_on_backdrop_value] = false
        data[:ui_dialog_close_on_escape_value] = false
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
