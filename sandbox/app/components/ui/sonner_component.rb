# frozen_string_literal: true

module Ui
  # The Sonner toaster: a fixed, polite live region that stacks transient
  # notifications. Drop a single instance into your layout, then push toasts
  # from anywhere with `window.toast({ title:, description:, variant:,
  # duration: })`. A button inside the same controller scope can also enqueue
  # one declaratively with `data-action="click->ui-sonner#toast"` and
  # `data-ui-sonner-*-param` attributes (see `ui_sonner` block usage).
  #
  # Hand-rolled — no `sonner` dependency. `variant` is one of :default,
  # :success, :error, :warning, :info.
  class SonnerComponent < UiComponent
    POSITIONS = {
      "top-left": "top-0 left-0 sm:items-start",
      "top-center": "top-0 left-1/2 -translate-x-1/2 sm:items-center",
      "top-right": "top-0 right-0 sm:items-end",
      "bottom-left": "bottom-0 left-0 sm:items-start",
      "bottom-center": "bottom-0 left-1/2 -translate-x-1/2 sm:items-center",
      "bottom-right": "bottom-0 right-0 sm:items-end"
    }.freeze

    def initialize(position: :"bottom-right", duration: 4000, class_name: nil, **attrs)
      @position = position
      @duration = duration
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.section(**section_attrs) do
        safe_join([ list, content ])
      end
    end

    private

    def section_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = @class_name.presence
        attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
          data[:slot] = "sonner"
          data[:controller] = append_token(data[:controller], "ui-sonner")
          data[:"ui-sonner-duration-value"] = @duration
        end
      end
    end

    def list
      tag.ol(
        "",
        role: "region",
        aria: { live: "polite", label: "Notificações" },
        tabindex: "-1",
        data: { slot: "sonner-list", "ui-sonner-target": "list" },
        class: class_names(
          "pointer-events-none fixed z-100 flex max-h-screen w-full flex-col gap-2 p-4 sm:max-w-[420px]",
          fetch_variant(POSITIONS, @position, fallback: :"bottom-right")
        )
      )
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
